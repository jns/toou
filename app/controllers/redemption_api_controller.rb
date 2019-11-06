class RedemptionApiController < ApiBaseController

    
    # Return merchant info
    # @param authorization a Device auth token
    # @param merchant_id the ID of the merchant the authorized device belongs to
    # @return merchant name and address 
    def merchant_info
        merchant = @current_user.merchant
        render json: {name: merchant.name, address: merchant.address}, status: :ok
    end
    
    # Return device info
    def device_info
        device = @current_user
        render json: {id: device.id, device_id: device.device_id, merchant_id: device.merchant_id}, status: :ok
    end
    
    # Get a temporary redemption code to use at a merchant
    # @params authorization A customer token
    # @params merchant_id A merchant id
    # @params pass_sn A pass serial number
    def get_code

        merchant = paramsMerchant
        pass = paramsPass 
        
        begin
            authorize pass
        
            cmd = AddPassToMerchantQueue.call(merchant, pass, @current_user)
            if cmd.success? 
                render json: {code: cmd.result}, status: :ok
            else
              render json: cmd.errors[:unredeemable], status: :bad_request 
            end  
        rescue  Pundit::NotAuthorizedError
            render json: {}, status: :not_found
        end
        
    end
    
    # Return the code and cancel the redemption
    # @param authorization A customer auth token
    # @param data[:merchant_id] The merchant id currently associated with the pass and the code
    # @param data[:pass_sn] The pass serial number
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
    # @param a Device auth token
    # @param a toou voucher code
    # @return 200 if successful
    def redeem
        code = params.require(:data).require(:code)
        authorize Device
        cmd = CaptureOrder.call(@current_user.merchant, code)
        if cmd.success?
            result = cmd.result
            buyable = result.buyable
            render json: {amount: "$%0.2f" % (result.transfer_amount_cents/100.0), buyable_type: buyable.class.name, buyable_name: buyable.name}, status: :ok
        else
            render json: cmd.errors, status: :bad_request 
        end
    end
    
    def redeemed
       authorize Device
       @currenet_user.merchant.credits
       render 'charges.json.jbuilder', status: :ok
    end
    
    private
    
    def paramsMerchant
        Rails.logger.debug params.inspect
        data = params.require(:data).permit(:merchant_id)
        Merchant.find(data[:merchant_id])
    end 
    
    def paramsPass
        data = params.require(:data).permit(:pass_sn, :group_id)

        if SerialNumber.isValid? data[:pass_sn]
            pass = Pass.find_by(serial_number: data[:pass_sn])
            if pass.recipient.is_a? Group
                return GroupPass.find(pass.id)
            else
                return pass
            end
        elsif g = Group.find(data[:group_id])
            pass = g.group_passes.valid_passes.order(created_at: :asc).first
        end
    end 
    
end