class MerchantApiController < ApiBaseController

	include MerchantsHelper
	

	skip_before_action :authorize_request, only: [:authorize_device]

    # Lists all merchants in scope
    def merchants
        @merchants = Merchant.where(user: @current_user)
        render 'merchants.json.jbuilder', status: :ok
    end

    def products
        @merchant = merchant_params
        authorize @merchant

        if request.put? 
            data = params.require(:data).permit(products: [:id, :can_redeem, :price_cents])
            data[:products].each do |p|
                product = Product.find(p["id"])
                mp = MerchantProduct.find_by(product: product, merchant: @merchant)
                if mp
                    if p["can_redeem"] == "false" || p["can_redeem"] == false
                        mp.destroy
                    elsif p["price_cents"]
                        mp.update(price_cents: p["price_cents"])
                    end
                elsif p["can_redeem"] == "true" || p["can_redeem"] == true
                    price_cents = p["price_cents"] || product.max_price_cents
                    MerchantProduct.create(merchant: @merchant, product: product, price_cents: price_cents)
                end
            end
        end        
       @products = Product.all
       render 'products.json.jbuilder', status: :ok
    end

    def create
        begin
            data = params.require(:data).permit(:name, :website, :phone_number, :address1, :address2, :city, :state, :country, :zip, :latitude, :longitude)
            data[:country] = Country.find_by(abbreviation: data[:country]) if data[:country]
            data[:user] = @current_user
            @merchant = Merchant.create(data)
            @products = Product.all
            render 'merchant_new.json.jbuilder', status: :ok
        rescue Error => e
            render json: {error: e.message}, status: :bad_request
        end
    end

    def merchant
        @merchant = merchant_params
        authorize @merchant
        if request.put?
            data = params.require(:data).permit(:name, :website, :phone_number, :address1, :address2, :city, :state, :country, :zip, :latitude, :longitude)
            data[:country] = Country.find_by(abbreviation: data[:country]) if data[:country]
            @merchant.update(data)
        end
        @products = Product.all
        render 'merchant_new.json.jbuilder', status: :ok
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
                elsif acct= EmailAccount.find_by(email: auth["email"].downcase) and acct.authenticate(auth["password"])
                    @current_user = acct.user
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
       
       @devices = merchant.devices
       render 'devices.json.jbuilder', status: :ok
    end

    # Return the stripe link for either connecting or accessing the dashboard
    def stripe_link
        @merchant = merchant_params
        authorize @merchant
    	if (@merchant.stripe_id == nil)
    		render json: {url: stripe_connect_url, type: "connect"}, status: :ok
    	else
    	    begin 
    		    render json: {url: stripe_dashboard_url(@merchant.stripe_id), type: "dashboard"}, status: :ok
    	    rescue Exception => e
    	        Log.create(context: "stripe_link", current_user: @merchant.id, message: e.message, log_type: Log::ERROR)
    	        render json: {error: "Error retrieving stripe link"}, status: :internal_server_error
    	    end
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