class MerchantsController < ApplicationController

    layout "merchant"
    include MerchantsHelper
    
    #skip_before_action :validate_auth_token
    skip_before_action :set_user, only: [:enroll, :onboard1, :onboard2, :onboard3]
    
    # Placeholder to retrieve an authentication token after already logged in and session is established
    def get_auth_token 
        token = JsonWebToken.encode(user_id: @current_user.id, user_type: "User")
        render json: {auth_token: token}, status: :ok
    end
    
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
        @merchant = Merchant.create(merchant_params)
        @merchant.user = @current_user
        @merchant.save
        redirect_to action: "index"
    end
    
    def edit
       set_merchant
       authorize @merchant
    end
    

    def show
       set_merchant
       authorize @merchant
       @products = Product.all
    end

    
    def update
        set_merchant
        authorize @merchant
        
        # Update merchant properties if provided
        data = merchant_params
        @merchant.update(data)
        redirect_to action: :show
    end
    
    def update_products
        set_merchant
        authorize @merchant
        
        products = merchant_products
        Product.all.each do |p|
            if products[p.id.to_s] and products[p.id.to_s]["can_redeem"]
                @merchant.add_product(p)
            else
                @merchant.remove_product(p)
            end
        end
        redirect_to action: :show
    end
    
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
    
    def device_not_authorized
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
        rescue ActiveRecord::RecordNotFound
            render json: {error: "Merchant Not Found"}, status: :not_found
        rescue Stripe::InvalidRequestError
            render json: {error: "Error connecting to Stripe"}, status: :bad_request
        rescue 
            render json: {error: "User not authorized"}, status: :unauthorized
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
