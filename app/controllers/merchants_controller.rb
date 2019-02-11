class MerchantsController < ApplicationController

    skip_before_action :validate_auth_token
    before_action :set_user
    
    # presents the welcome screen
    def index
        if @current_user
            @merchants = Merchant.where(user: @current_user)
            render 'dashboard'
        else
            @user = User.new
            render 'login'
        end
    end
    
    def new_user
        if request.get?
            @new_user = User.new
        elsif request.post? 
            user_params = params.require(:user).permit(:username, :password)
            user = User.create(user_params)
            user.roles << Role.merchant
            set_user(user)
            redirect_to action: 'index'
        end
    end
    
    def login
        if request.get?
            @user = User.new
            render 'login'
        elsif request.post?
            user_params = params.require(:user).permit(:username, :password)
            user = User.find_by(username: user_params[:username]) 
            if user and user.authenticate(user_params[:password])
                flash[:notice] = ""
                set_user(user)
                redirect_to action: "index" 
            else
                flash[:notice] = "Invalid login credentials"
                render 'login', status: :unauthorized
            end       
        end
    end
    
    def logout
        reset_session
        redirect_to action: 'index'
    end
    
    def new
       @merchant = Merchant.new
    end
    
    # POST creates a new merchant with data from the form
    def create
        merchant_params = params.require(:merchant).permit(:name, :website, :phone_number)
        @merchant = Merchant.create(merchant_params)
        @merchant.user = @current_user
        @merchant.save
        redirect_to action: "index"
    end
    
    def show
       set_merchant 
    end
    
    # GET enrolls a new merchant with stripe
    def enroll
        state, code = params.require([:state, :code])
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
    
    def set_user(user = nil)
        if user
            session[:user_id] = user.id
        elsif session[:user_id]
            begin
                @current_user = User.find(session[:user_id])
            rescue ActiveRecord::RecordNotFound
                reset_session
                @current_user = nil
            end
        end
    end
    
    def set_merchant
        @merchant = Merchant.find(params[:id]) 
    end
end
