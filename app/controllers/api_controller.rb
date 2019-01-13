class ApiController < ActionController::Base

    include PassesHelper

    # autheticates user with JWT
    before_action :authorize_request, except: [:requestOneTimePasscode, :redeemCode, :authenticate]
    

    # Delivers a one time passcode to the users mobile device 
    #
    # @param [String] phoneNumber The phone number of the device to deliver a one time passcode
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
            rescue => err 
                Log.create(log_type: Log::ERROR, context: "ApiController#requestOneTimePasscode", current_user: @current_user.id, message: err.to_s)
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
    
    # Places an order for passes to be delivered to recipients
    # @param Array of phone numbers who will receive passes
    # @param String the message to include in the delivered pass
    def placeOrder
        recipients, message = params.require([:recipients, :message])
        command = PlaceOrder.call(@current_user, recipients, message)
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
    
end
