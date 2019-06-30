class RedemptionApiController < ApiBaseController

    
    # Return merchant info
    # @param auth_token
    # @return
    def merchant_info
        if @current_user.is_a? Merchant
            render json: {name: @current_user.name, address: @current_user.address}, status: :ok
        else
            render json: {}, status: :unauthorized
        end
    end
    
    # Get a temporary redemption code to use at a merchant
    def get_code

        merchant = paramsMerchant
        pass = paramsPass 
        
        begin
            authorize pass
        
            cmd = AddPassToMerchantQueue.call(merchant, pass)
            if cmd.success? 
                render json: {code: cmd.result}, status: :ok
            else
              render json: cmd.errors, status: :bad_request 
            end  
        rescue  Pundit::NotAuthorizedError
            render json: {}, status: :not_found
        end
        
    end
    
    # Return the code and cancel the redemption
    def cancel_code
        merchant = paramsMerchant
        pass = paramsPass 
        
        begin 
            cmd = RevokePassFromMerchantQueue.call(merchant, pass)
            if cmd.success?
               render json: {}, status: :ok 
            else
                render json: cmd.errors, status: :bad_request
            end
        rescue Pundit::NotAuthorizedError
            render json: {}, status: :not_found
        end
    end
    
    # Redeem a Toou Voucher 
    # @param auth_token
    # @param a toou voucher code
    # @return 200 if successful
    def redeem
        code = params.require(:data).require(:code)
        authorize Device
        cmd = CaptureOrder.call(@current_user.merchant, code)
        if cmd.success?
            render json: {amount: "$%0.2f" % (cmd.result.transfer_amount_cents/100.0)}, status: :ok
        else
            render json: cmd.errors, status: :bad_request 
        end
    end
    
    private
    
    def paramsMerchant
        Rails.logger.debug params.inspect
        data = params.require(:data).permit(:merchant_id)
        Merchant.find(data[:merchant_id])
    end 
    
    def paramsPass
        data = params.require(:data).permit(:pass_sn)
        if SerialNumber.isValid? data[:pass_sn]
            Pass.find_by(serial_number: data[:pass_sn])
        end
    end 
    
end