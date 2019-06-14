class RedemptionApiController < ApiBaseController

    skip_before_action :authorize_request
    
   # Authorize a device to redeem Toou Vouchers on behalf of a merchant
    # @param [Int] the merchant id
    # @return [json] an authentication token {auth_token: token}
    def authorize_device
        merch_id = params.require(:merchant_id)
        merchant = Merchant.find(merch_id)
        command = CreateRedemptionAuthToken.call(merchant)
       if command.success?
           render json: {auth_token: command.result}, status: :ok
       else
           render json: {error: command.errors}, status: :unauthorized
       end
    end
    
    # Return merchant info
    # @param auth_token
    # @return
    def merchant_info
        token = params.require(:auth_token)
        decoded_token = JsonWebToken.decode(token)
        if decoded_token === nil 
            render json: {}, status: :unauthorized
        else
            merchant_id = decoded_token[:merchant_id] 
            begin
                merchant = Merchant.find(merchant_id)
                render json: {name: merchant.name}, status: :ok
            rescue
               render json: {}, status: :bad_request
            end
        end
    end
    
    # Redeem a Toou Voucher 
    # @param auth_token
    # @param a toou voucher code
    # @return 200 if successful
    def redeem
        token, code = params.require([:auth_token, :code])
        decoded_token = JsonWebToken.decode(token)
        if decoded_token === nil
          render json: {}, status: :bad_request
        else
           merchant_id = decoded_token[:merchant_id] 
           begin
                merchant = Merchant.find(merchant_id)
                if (code =~ /\d{4}/ and code === "0000")
                    render json: {amount: "$9"}, status: :ok
                else
                    render json: {}, status: :bad_request
                end
           rescue
               render json: {}, status: :unauthorized
           end
           

        end
    end
    
end