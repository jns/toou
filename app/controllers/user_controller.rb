class UserController < ApplicationController

    # skip_before_action :set_user, except: [:new_user]

    def password_reset
    end

    def new_merchant
        authorize User, :new?
        if request.get?
            @new_user = User.new
        elsif request.post? 
            user_params = params.require(:user).permit(:username, :password)
            user_params[:email] = user_params[:username]
            if User.find_by(email: user_params[:email])
                flash[:notice] = "Account already exists"
                redirect_to :login
                return
            end 
            
            user = User.create(user_params)
            if user.id
                user.roles << Role.merchant
                set_user(user)
                redirect_to controller: :merchants, action: :index
            else
               flash[:notice] = "Please use an email for username"
               @new_user = user
            end
        end
    end
    
    def login
        authorize User
        if request.get?
            @user = User.new
            render 'login'
        elsif request.post?
            user_params = params.require(:user).permit(:username, :password)
            user = User.find_by(email: user_params[:username].downcase) 
            if user and user.authenticate(user_params[:password])
                flash[:notice] = ""
                set_user(user)
                destination = user_home(user)
                
                redirect_to destination
            else
                flash[:notice] = "Invalid login credentials"
                render 'login', status: :unauthorized
            end       
        end
    end

    def logout
        reset_session
        redirect_to '/'
    end
    
    private
    
    def user_home(user)
        if user.admin?
            return admin_path
        elsif user.merchant?
            return merchants_path
        else
            return "/"
        end
    end
end