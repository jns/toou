class MerchantApiController < ApiBaseController

	include MerchantsHelper
	

	skip_before_action :authorize_request, only: [:authenticate_merchant, :authorize_device]

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
    
    def products
        @merchant = merchant_params
        authorize @merchant
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
        @merchant = merchant_params
        authorize @merchant
        if request.put?
            data = params.require(:data).permit(:name, :website, :phone_number, location: [:address1, :address2, :city, :state, :zip, :latitude, :longitude])
            @merchant.update(name: data[:name], website: data[:website], phone_number: data[:phone_number])
            if data[:location]
               @merchant.update(address1: data[:location][:address1],
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

    
    # Authorize a device to redeem Toou Vouchers on behalf of a merchant
    # @param authorization a merchant user auth token
    # @param [merchant_id] the merchant id
    # @param [device_id] the device id
    # @return [json] an authentication token {auth_token: token}
    def authorize_device
        cmd = AuthorizeApiRequest.call(request.params)
        if cmd.success?
            @current_user = cmd.result
            @merchant = merchant_params
        else
            begin
                auth = params.require(:authorization).permit(:email, :password, :secret)

                if secret = auth["secret"] and Secret.exists?(secret)
                    @current_user = Secret.find(secret)
                    @merchant = merchant_params
                elsif u= User.find_by(email: auth["email"].downcase) and u.authenticate(auth["password"])
                    @current_user = u
                    merchants = @current_user.merchants
                    if merchants.count == 1
                        render json: {secret: Secret.create(@current_user), merchants: [merchants.first]}, status: :ok
                        return
                    else
                        render json: {secret: Secret.create(@current_user), merchants: merchants.collect{|m| {id: m.id, name: m.name}}}, status: :ok
                        return
                    end
                else
                    raise "Unauthorized"
                end
            rescue Exception => e
                render json: {error: "Unauthorized"}, status: :unauthorized
                return
            end
        end

        unless @merchant 
            render json: {error: "merchant not found"}, status: :bad_request
            return
        end

        authorize @merchant

        device_id = params.require(:data).require(:device_id)
        device = @merchant.authorize_device(device_id)
        command = CreateRedemptionAuthToken.call(device)
        if command.success?
           render json: {auth_token: command.result}, status: :ok
        else
           render json: {error: command.errors}, status: :unauthorized
        end
    end
    
    # Deauthorizes a device belonging to a merchant    
    def deauthorize_device
        merchant = merchant_params
        authorize merchant
        
        device_id = params.require(:data).require(:device_id)
        merchant.deauthorize_device(device_id)
        render json: {}, status: :ok
    end 
    
    def authorized_devices
       merchant = merchant_params
       authorize merchant
       
       @devices = policy_scope(Device).select{|d| d.merchant === merchant}
       render 'devices.json.jbuilder', status: :ok
    end

    # Return the stripe link for either connecting or accessing the dashboard
    def stripe_link
        @merchant = merchant_params
        authorize @merchant
    	if (@merchant.stripe_id == nil)
    		render json: {url: stripe_connect_url}, status: :ok
    	else
    		render json: {url: stripe_dashboard_url(@merchant.stripe_id)}, status: :ok
    	end
    end
    
    # Returns all credits for a merchant
    def credits
        merchant = if @current_user.is_a? Device
            @current_user.merchant
        else
            merchant_params
        end
        authorize merchant
        @charges = merchant.charges
        render 'charges.json.jbuilder', status: :ok
    end

    private
    
    def merchant_params
       merchant_id = params.require(:data).require(:merchant_id) 
       Merchant.find(merchant_id)
    end
   
end