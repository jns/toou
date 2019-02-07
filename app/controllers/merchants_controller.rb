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
        @user = User.new
    end
    
    def authenticate
        user_params = params.require(:user).permit(:username, :password)
        user = User.find_by(username: user_params[:username]) 
        if user and user.authenticate(user_params[:password])
            set_user(user)
        else
            flash[:notice] = "Invalid login credentials"
        end
        redirect_to action: "index"
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
    
    # GET enrolls a new merchant with stripe
    def enroll
        state, code = params.require([:state, :code])
        merchant = Merchant.find(state)
        unless merchant
            redirect_to merchants_url
        end
        
        cmd = EnrollStripeConnectedAccount.call(merchant, code)
        if cmd.success?
            redirect_to action: 'dashboard'
        else
            redirect_to merchants_url
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
end
