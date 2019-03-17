class MerchantsController < ApplicationController

    include MerchantsHelper
    
    #skip_before_action :validate_auth_token
    skip_before_action :set_user, only: [:enroll, :new_user, :onboard1, :onboard2, :onboard3]
    
    # Info message for now
    def new_user
    end
    
    # presents the welcome screen
    def index
        if @current_user
            authorize Merchant
            @merchants = policy_scope(Merchant)
            render 'dashboard'
        else
            redirect_to controller: 'user', action: 'login'
        end
    end
    
    def onboard1
        
    end
    
    def onboard2
        
    end
    
    def onboard3
        @merchant = Merchant.first
    end
    
    
    def new
        authorize Merchant
       @merchant = Merchant.new
    end
    
    # POST creates a new merchant with data from the form
    def create
        authorize Merchant
        merchant_params = params.require(:merchant).permit(:name, :website, :phone_number)
        @merchant = Merchant.create(merchant_params)
        @merchant.user = @current_user
        @merchant.save
        redirect_to action: "index"
    end
    
    def show
       set_merchant
       authorize @merchant
    end

    
    # GET enrolls a new merchant with stripe
    def enroll
        authorize Merchant
        state, code = params.require([:state, :code])
        
        if code === "TEST_OK"
            return head :ok
        end
        
        merchant = Merchant.find(state)
        unless merchant
            render status: :bad_request
        end
        
        cmd = EnrollStripeConnectedAccount.call(merchant, code)
        if cmd.success?
            redirect_to action: 'index'
        else
            flash[:notice] = cmd.errors(:enrollment_error)
            redirect_to merchants_url
        end
    
    end
    
    def stripe_dashboard_link 
        begin
            m = Merchant.find(params["id"])
            authorize m
            if m.stripe_id
                account = Stripe::Account.retrieve(m.stripe_id)
                links = account.login_links.create()
                render json: links, status: :ok
            else
               render json: {error: "Merchant is not enrolled in Stripe"}, status: :bad_request 
            end
        rescue
            render json: {error: "Merchant Not Found"}, status: :not_found
        end
    end
    
    private
    
    def set_merchant
        @merchant = Merchant.find(params[:id]) 
    end
end
