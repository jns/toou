class MerchantsController < ApplicationController

    layout 'application_no_js_routing'

    include MerchantsHelper
    
    #skip_before_action :validate_auth_token
    skip_before_action :set_user, only: [:enroll]
    
    # GET enrolls a new merchant with stripe
    def enroll
        authorize Merchant
        state, code = params.require([:state, :code])
        
        if code === "TEST_OK"
            @merchant = Merchant.new(name: "Test")
            render status: :ok
            return
        end
        
        if code === "TEST_ERROR"
           @error = "Testing error"
           render status: :ok
           return
        end
        
        begin
            @merchant = Merchant.find(state)
            cmd = EnrollStripeConnectedAccount.call(@merchant, code)
            unless cmd.success?
                @error = cmd.errors[:enrollment_error]
            end
        rescue ActiveRecord::RecordNotFound
            render status: :bad_request
        end
    end

    private
    
    def set_merchant
        @merchant = Merchant.find(params[:id]) 
    end
    
    def merchant_params
        params.require(:merchant).permit(:name, :website, :phone_number, :address1, :city, :state, :zip)
    end
    
    def merchant_products
       params.require(:products)
    end
end
