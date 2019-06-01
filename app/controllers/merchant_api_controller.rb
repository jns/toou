class MerchantApiController < ApiBaseController

	include MerchantsHelper
	

	skip_before_action :authorize_request, only: [:request_passcode, :authenticate_merchant, :authenticate_device]

    def products
        @merchant = @current_user.merchant
        if request.put?
            data = params.require(:data).permit(product: [:id, :can_redeem, :price_cents])
            product = Product.find(data[:product][:id])
            mp = MerchantProduct.find_by(product: product)
            if mp
                if data[:product][:can_redeem] === "false"
                    mp.destroy
                else
                    mp.update(price_cents: data[:product][:price_cents])
                end
            else
                MerchantProduct.create(merchant: @merchant, product: product, price_cents: data[:product][:price_cents])
            end
        end        
       @products = Product.all
       render 'products.json.jbuilder', status: :ok
    end

    def merchant
        @merchant = @current_user.merchant
        if request.put?
            data = params.require(:data).permit(:name, :website, :phone_number, location: [:address1, :address2, :city, :state, :zip, :latitude, :longitude])
            @merchant.update(name: data[:name], website: data[:website], phone_number: data[:phone_number])
            if data[:location]
               l = @merchant.locations.first 
               l.update(address1: data[:location][:address1],
                        address2: data[:location][:address2],
                        city: data[:location][:city],
                        state: data[:location][:state],
                        zip: data[:location][:zip],
                        latitude: data[:location][:latitude],
                        longitude: data[:location][:longitude])
            end
        end
        render 'merchant.json.jbuilder', status: :ok
    end

    # Authenticate a merchant user
    # @param [String] username The merchant's username
    # @param [String] password The merchant's password
    def authenticate_merchant 
       credentials = params.require(:data).permit([:username, :password])
       command = CreateAuthToken.call(credentials[:username], credentials[:password])
       if command.success?
           render json: {auth_token: command.result}, status: :ok
       else
           render json: {error: command.errors}, status: :unauthorized
       end
    end
    
    # Authenticate a merchant on a device using a passcode
    # @param [String] device the merchant's device 
    # @param [String] passcode the temporary passcode
    # @return [json] an authentication token
    def authenticate_device
        credentials = params.require(:data).permit([:device, :password])
        dev = Device.find_by(device_id: credentials[:device])
        command = CreateDeviceAuthToken.call(dev, credentials[:password])
        if command.success?
            render json: {auth_token: command.result}, status: :ok
        else
            render json: {error: command.errors}, status: :unauthorized
        end
    end
    
    # Deauthorizes a device belonging to a merchant    
    def deauthorize_device
        data = params.require(:data).permit(:device)
        @current_user.deauthorize_device(data[:device])
        render json: {}, status: :ok
    end 
    
    # Verify a device
    def verify_device
       data = params.require(:data).permit(:device)
       if @current_user.devices.collect{|d| d.device_id }.member?(data[:device])
           render json: {}, status: :ok
       else
           render json: {}, status: :unauthorized
       end
    end
    
    # Delivers a one time passcode to the merchant's email 
    #
    # @param [String] email The email of the user to deliver a one time passcode
    # @param [String] deviceId A unique id of the device 
    # @return 200 For a valid phone number and deviceID
    # @return 400 For an invalid email or a suspicious deviceId    
    def request_passcode
        data = params.require(:data).permit([:email, :device_id])
        
        user = User.find_by(email: data[:email])
        if user
            otp = user.generate_otp_for_device(data[:device_id]) 
            MerchantNotificationsMailer.with(user: user, passcode: otp).passcode_email.deliver_later unless user.tester?
           render json: {}, status: :ok
        else
            render status: :unauthorized, json: {error: "Email Address not found"}
        end
    end

    def stripe_link
        @merchant = @current_user.merchant
        if @merchant 
        	if (@merchant.stripe_id == nil)
        		render json: {url: stripe_connect_url}, status: :ok
        	else
        		render json: {url: stripe_dashboard_url(@merchant.stripe_id)}, status: :ok
        	end
        else
            return head :bad_request
        end
    end
    
    # Returns all credits for a merchant
    def credits
        merchant = @current_user.merchant
        @charges = merchant.charges
        render 'charges.json.jbuilder', status: :ok
    end

    # Redeems a specific product
    def redeem
        data = params.require(:data).permit(:serial_number)
        
        begin
            merchant = @current_user.merchant
            authorize merchant
            
            if not SerialNumber.isValid?(data[:serial_number])
                render json: {error: "Invalid Serial Number"}, status: :bad_request and return
            end
            
            pass = Pass.where("serial_number like ?", "#{data[:serial_number]}%").take
        
            if pass 
                cmd = CaptureOrder.call(merchant, pass)
                if cmd.success?
                    render json: {message: "Pass Redeemed", 
                                  product: {id: pass.buyable.id, name: pass.buyable.name},
                                  amount_cents: pass.charge.destination_amount_cents}, 
                            status: :ok
                else
                    render json: {error: cmd.errors.to_json}, status: :bad_request
                end
            else
                render json: {error: "Pass Not Found"}, status: :not_found
            end
        rescue ActiveRecord::RecordNotFound => e
            render json: {error: "Not Authorized"}, status: :unauthorized
        end
    end

end