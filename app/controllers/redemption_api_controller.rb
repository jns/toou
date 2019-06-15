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
    
    # Get a temporary redemption code to use at a merchant
    def get_code
        code = Random.new.rand(10000)
        if code < 5000
            render json: {code: "%04d" % code}, status: :ok
        else
            render json: {}, status: :bad_request
        end
        # auth_token, data = params.require([:auth_token, data: [:merchant_id, :pass_sn]])
        # decoded_token = JsonWebToken.decode(token)
        # if decoded_token === nil
        #   render json: {}, status: :unauthorized
        # else
        #   merchant_id = decoded_token[:merchant_id] 
        #   merchant = nil
        #   pass = nil
        #   begin
        #         Merchant.find(merchant_id)
        #         Pass.find_by(serial_number: data)
        #     rescue
        #         # Invoked if Merchant not found
        #       render json: {}, status: :unauthorized
        #       return
        #     end
            
        #     cmd = AddPassToMerchantQueue.call(merchant, pass)
            
        #     if cmd.success? 
        #         render json: {code: cmd.result}, status: :ok
        #     else
        #       render json: cmd.errors, status: :bad_request 
        #     end
        # end
    end
    
    # Redeem a Toou Voucher 
    # @param auth_token
    # @param a toou voucher code
    # @return 200 if successful
    def redeem
        token, code = params.require([:auth_token, :code])
        decoded_token = JsonWebToken.decode(token)
        if decoded_token === nil
          render json: {}, status: :unauthorized
        else
           merchant_id = decoded_token[:merchant_id] 
           merchant = begin
                Merchant.find(merchant_id)
            rescue
                # Invoked if Merchant not found
               render json: {}, status: :unauthorized
               return
            end     
            
            charge = CaptureOrder.call(merchant, code)
            if charge.success?
                render json: {amount: "$%0.2f" % charge.destination_amount_cents/100.00}, status: :ok
            else
                render json: charge.errors, status: :bad_request 
            end
            
        end
    end
    
end