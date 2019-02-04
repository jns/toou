class ApiController < ApiBaseController

    include PassesHelper

    # autheticates user with JWT
    skip_before_action :authorize_request, only: [:requestOneTimePasscode, :redeemCode, :authenticate, :promotions, :order]
    

    def promotions
        @promotions = Promotion.where(status: Promotion::ACTIVE)
        render 'promotions.json.jbuilder', status: :ok
    end

    # Delivers a one time passcode to the users mobile device 
    #
    # @param [String] phone_number The phone number of the device to deliver a one time passcode
    # @param [String] deviceId A unique id of the device 
    # @return 200 For a valid phone number and deviceID
    # @return 400 For an invalid phone number or a suspicious deviceId    
    def requestOneTimePasscode
        
        acct_phone_number = params.require(:phone_number)
        device_id = params.permit(:device_id)[:device_id]
            
        phone = PhoneNumber.new(acct_phone_number).to_s
        if (phone) 
            acct = Account.find_or_create_by(phone_number: phone)
            if (! acct)
                Log.create(log_type: Log::ERROR, context: "ApiController#requestOneTimePasscode", current_user: @current_user.id, message: "Error Creating Account with phone number #{phone}")
                render status: :internal_server_error, json: {error: "Error creating account"}
            end
            
            if device_id and !device_id.empty?
                acct.device_id = device_id
                acct.save
            end
            
            # Todo check the device ID and get worried if it changed
            otp = acct.generate_otp 
            begin
                MessageSender.new.send_code(phone.to_s, otp)
            rescue Exception => err 
                Log.create(log_type: Log::ERROR, context: "ApiController#requestOneTimePasscode", current_user: phone, message: err.message)
                render status: :internal_server_error, json: {error: "Error sending SMS"}
                return
            end
           render json: {passcode: otp}, status: :ok
            
        else
            render status: :bad_request, json: {error: "Invalid phone number."}
        end

            
    end
    
    # Delivers a one time passcode to the users mobile device
    # based on a redemption code linked to a mobile device
    #
    # @param [String] redemptionCode the redemption code 
    # @return 200 For a valid redemption code
    # @return 400 For an invalid redemption code
    def redeemCode
        
    end
    
    
    # Authenticates the parameters and returns a json web token
    # @param [String] phone_number The phone number of the device to authenticate
    # @param [String] pass_code a one time passcode returned by requestOneTimePasscode
    # @return 200 {"auth_token", jwt} a json web token or 401 for an invalid set of credentials
    def authenticate
        otp, phoneNumber = params.require([:pass_code, :phone_number])
        command = AuthenticateUser.call(phoneNumber, otp)
    
       if command.success?
         render json: { auth_token: command.result }, status: :ok
       else
         render json: { error: command.errors }, status: :unauthorized
       end
    end
    
    # Alternate order that doesn't require auth
    # @param a purchaser name, phone, and email
    # @param recipients a list of phone numbers
    # @param payment_source a stripe payment token
    # @param promotion_id the promotion being purchased
    def order
        purchaser = params.require(:purchaser).permit(:name, :phone, :email)
        recipients, payment_source = params.require([:recipients, :payment_source])
        message = params.permit(:message)[:message]
        
        # Sanitize and format the phone number
        phone = PhoneNumber.new(purchaser[:phone]).to_s
        unless phone
            render json: {error: "Invalid Phone Number"}, status: :bad_request
            return
        end
        
        # Find or generate an account
        acct = Account.find_or_create_by(phone_number: phone)
        acct.email = purchaser[:email]
        acct.save
        

        # Place the order
        command = PlaceOrder.call(acct, payment_source, recipients, message, product)
        if command.success?
            render json: {}, status: :ok
        else
            render json: {error: "Please provide a valid phone number"}, status: :bad_request
        end
    end

    
    # Places an order for passes to be delivered to recipients
    # @param recipients Array of phone numbers who will receive passes
    # @param message String the message to include in the delivered pass
    # @param payment_source String a payment token
    # @param promotion_id String an id of the item being purchased (optional)
    def placeOrder
        recipients, message, payment_source = params.require([:recipients, :message, :payment_source])
        
        command = PlaceOrder.call(@current_user, payment_source, recipients, message, product)
        if command.success?
            render json: {order_id: command.result.id}, status: :ok
        else
            render json: {error: command.errors}, status: :bad_request
        end
    end

    
    # Returns available passes for authenticated user
    # 
    def passes
        command = RequestPasses.call(@current_user, serialNumbers)
        if command.success?
            @passes = command.result
            render 'passes.json.jbuilder', status: :ok
        else
            render json: {error: command.errors}, status: :bad_request
        end
    end
    
    #
    # Returns the purchase and pass history for an authenticated user
    def history
       command = AccountHistory.call(@current_user)
       if command.success?
           @history = command.result
           render 'history.json.jbuilder', status: :ok
       else
           render json: {error: command.errors}, status: :bad_request
       end
    end
    
    # Returns the specific pkpass if the user is authorized
    # Required Params
    # @param serial_number
    def pass
        
        serialNumber = serialNumberParam
        
        pass = @current_user.passes.find{|p| p.serialNumber == serialNumber}
        
        unless pass
            render json: {}, status: :not_found
            return
        end
        
        passFileName = passFileName(pass)
        
        # If pass doesn't exist then build pass on the fly
        if not File.exists?(passFileName)
            PassBuilderJob.new().perform(pass.id)
        end
        
        # If pass still doesn't exist there was an error, return internal server error
        if File.exists?(passFileName)
            send_file(passFileName, type: 'application/vnd.apple.pkpass', disposition: 'inline')
        else
            render json: {}, status: :internal_server_error
        end
    end
    
    private
    
    attr_reader :current_user

    def authorize_request
        @current_user = AuthorizeApiRequest.call(request.headers).result
        render json: { error: 'Not Authorized' }, status: 401 unless @current_user
    end
    
    def serialNumberParam
        value = params[:serial_number]
        if SerialNumber.isValid?(value)
            value
        else
            nil
        end
    end
    
    def serialNumbers
       values = params[:serialNumbers]
       if ! values.is_a? Array
           []
       else
          values.select{|v| SerialNumber.isValid?(v)} 
       end
    end
    
    def product
        product_id, product_type = params.require([:product_id, :product_type])
        
        case product_type
        when Product.name
            Product.find(product_id)
        when Promotion.name
            Promotion.find(product_id)
        else
            render json: {error: "Invalid product"}, status: bad_product
        end
    end
    
end
