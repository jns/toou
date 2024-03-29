class ApiController < ApiBaseController

    include PassesHelper

    # autheticates user with JWT
    skip_before_action :authorize_request, only: [:requestOneTimePasscode, :authenticate,:promotions, :products, :order, :initiate_order, :merchants]
    
    # Account details for the current user
    def account
        case request.method
        when "POST"
            data = params.permit(data: [:name, :email, :device_id])
            if data[:data]
                @current_user.name = data[:data][:name] if data[:data][:name]
                @current_user.email = data[:data][:email] if data[:data][:email]
                @current_user.device_id = data[:data][:device_id] if data[:data][:device_id] 
            end
            render json: {name: @current_user.name, email: @current_user.email, phone: @current_user.phone_number}, status: :ok
        else
            render json: {}, status: :bad_request
        end
    end
    
    # Retreive 
    def payment_methods
        methods = Stripe::PaymentMethod.list(customer: @current_user.stripe_customer_id, type: "card")
        render json: methods[:data], status: :ok
    end 
    
    # Returns active promotions
    def promotions
        @promotions = Promotion.where(status: Promotion::ACTIVE)
        render 'promotions.json.jbuilder', status: :ok
    end

    # returns products
    def products
        @products = Product.all
        render 'products.json.jbuilder', status: :ok
    end
    
    def merchants
        query = params.permit(query: {})
        query = query[:query] if query
        if query and query[:name]
            @merchants = Merchant.where("LOWER(name) like ?", "%#{query[:name].downcase}%")
        elsif query and query[:product_id]
            p = Product.find(query[:product_id])
            @merchants = p.merchants
        elsif query and query[:latitude] and query[:longitude]
            lat = query[:latitude].to_f
            lon = query[:longitude].to_f 
            @merchants = Merchant.all.distance_sort(lon, lat)
        else
            # Select all merchants with products
            @merchants = Merchant.joins(:merchant_products).distinct
        end
        @merchants = @merchants.select {|m| m.enrolled}
        render 'merchants.json.jbuilder', status: :ok
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
        name = params.permit(:name)[:name]
        email = params.permit(:email)[:email]
        
        begin
            acct = User.find_or_create_mobile_phone_account(acct_phone_number, email, name)
            if (! acct)
                Log.create(log_type: Log::ERROR, context: "ApiController#requestOneTimePasscode", current_user: @current_user.id, message: "Error Creating Account with phone number #{acct_phone_number}")
                render status: :internal_server_error, json: {error: "Error creating account"}
            end
            
            if device_id and !device_id.empty?
                acct.device_id = device_id
            end
            
            
            acct.save
            
            # Todo check the device ID and get worried if it changed
            otp = acct.generate_otp 
            begin
                MessageSender.new.send_code(acct.phone_number, "Your T👀U authentication code is #{otp}") unless acct.test_user?
            rescue Exception => err 
                Log.create(log_type: Log::ERROR, context: "ApiController#requestOneTimePasscode", current_user: acct_phone_number, message: err.message)
                # render status: :internal_server_error, json: {error: "Error sending SMS"}
                render status: :internal_server_error, json: {error: err.message}
                return
            end
           render json: {}, status: :ok
            
        rescue Exception => e
            render status: :bad_request, json: {error: e.message}
        end

            
    end

    
    # Authenticates the parameters and returns a json web token
    # @param [String] phone_number The phone number of the device to authenticate
    # @param [String] pass_code a one time passcode returned by requestOneTimePasscode
    # @return 200 {"auth_token", jwt} a json web token or 401 for an invalid set of credentials
    def authenticate
        otp, phoneNumber = params.require([:pass_code, :phone_number])
        
        begin 
            command = AuthenticateUser.call(phoneNumber, otp)
        
           if command.success?
               token = command.result
             render json: { auth_token: token, missing_fields: []}, status: :ok
           else
             render json: { error: "Invalid code"}, status: :unauthorized
           end
        rescue Exception => e
            render json: {error: e.message}, status: :internal_server_error
        end
    end

    # get groups a user belongs and the number of valid passes for
    # buyables in that group
    def groups
        
        
        @groups = @current_user.groups
        render 'groups.json.jbuilder', status: :ok
    end
    

    def initiate_order
        recipients, payment_source = params.require([:recipients, :payment_source])
        
        message = params.permit(:message)[:message]
        product = buyable_params
        fee = product.fee(:cents)
        
        
        cmd = AuthorizeApiRequest.call(params)
    
        if cmd.success? 
            @current_user = cmd.result
        else
            purchaser = params.require(:purchaser).permit(:name, :phone, :email)
            
            # Sanitize and format the phone number
            phone = PhoneNumber.new(purchaser[:phone]).to_s
            unless phone
                render json: {error: "Invalid Phone Number"}, status: :bad_request
                return
            end
            
            # Find or generate an account
            @current_user = User.find_or_create_mobile_phone_account(phone, purchaser[:email], purchaser[:name]).user
            
        end 

        # Update name and email if they are nil
        @current_user.email = purchaser[:email] unless @current_user.email
        @current_user.name = purchaser[:name] unless @current_user.name
        
        # Place the order
        command = InitiateOrder.call(@current_user, payment_source, recipients, message, product, fee)
        if command.success?
            if command.result.status == Order::OK_STATUS
                render json: {success: true}, status: :ok
            elsif command.result.status == Order::PENDING_STATUS
                render json: {requires_action: true, payment_intent_client_secret: command.result.payment_intent.client_secret}, status: :ok
            else
                render json: {success: false}, status: :bad_request
            end
        else
            render json: {error: command.errorDescription}, status: :bad_request
        end
        
    end

    def confirm_payment
        payment_intent_id = params.require(:data).require(:payment_intent_id)
        cmd = ConfirmPaymentIntent.call(payment_intent_id)
        intent = cmd.result
        if intent.status == "succeeded"
            CompleteOrder.call(Order.find_by(charge_stripe_id: intent.id))
            render json: {success: true}, status: :ok
        else
            # Need to cancel payment intent here.
            render json: {success: false}, status: :ok
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
    
    # Returns pass data for the user
    def pass 
        serialNumber = serialNumberParam
        unless @current_user.is_a? User 
            render json: {}, status: :unauthorized
            return
        end
        
        begin 
            @pass = Pass.find{|p| p.serial_number == serialNumber}
            authorize @pass
        rescue Pundit::NotAuthorizedError
            render json: {}, status: :not_found
        rescue ActiveRecord::RecordNotFound
            render json: {}, status: :not_found
        else
            render 'pass.json.jbuilder', status: :ok
        end
        
    end
    
    def request_group_pass
       data = params.require(:data).permit(:group_id, :buyable_id, :buyable_type)
       group = Group.find(data["group_id"])
       @pass = GroupPass.valid_passes.where(recipient: group, buyable_id: data["buyable_id"], buyable_type: data["buyable_type"]).first
    
        authorize @pass
        render 'pass.json.jbuilder', status: :ok
                
    end

    private
    
    
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
    
    def buyable_params
        buyable = params.require(:product).permit(:id, :type)
        
        case buyable["type"]
        when Product.name
            Product.find(buyable["id"])
        when Promotion.name
            Promotion.find(buyable["id"])
        else
            nil
        end
    end
    
end
