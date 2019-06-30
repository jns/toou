class MerchantApiController < ApiBaseController

	include MerchantsHelper
	

	skip_before_action :authorize_request, only: [:authenticate_merchant]

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
    # @param [merchant_id] the merchant id
    # @param [device_id] the device id
    # @return [json] an authentication token {auth_token: token}
    def authorize_device
        merchant = merchant_params
        authorize merchant
        
        device = params.require(:data).require(:device_id)
        command = CreateRedemptionAuthToken.call(merchant, device)
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
        device = merchant.devices.find{|d| d.device_id == device_id}
        device.destroy if device
        render json: {}, status: :ok
    end 
    

    # Return the stripe link for either connecting or accessing the dashboard
    def stripe_link
        @merchant = merchant_params
        authorize merchant
    	if (@merchant.stripe_id == nil)
    		render json: {url: stripe_connect_url}, status: :ok
    	else
    		render json: {url: stripe_dashboard_url(@merchant.stripe_id)}, status: :ok
    	end
    end
    
    # Returns all credits for a merchant
    def credits
        merchant = merchant_params
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