class UserController < ApplicationController

    skip_before_action :set_user, except: [:new_user]

    def new_user
        authorize User, :new?
        if request.get?
            @new_user = User.new
        elsif request.post? 
            user_params = params.require(:user).permit(:username, :password)
            user = User.create(user_params)
            user.roles << Role.merchant
            set_user(user)
            redirect_to action: 'login'
        end
    end
    
    def login
        authorize User
        if request.get?
            @user = User.new
            render 'login'
        elsif request.post?
            user_params = params.require(:user).permit(:username, :password)
            user = User.find_by(username: user_params[:username]) 
            if user and user.authenticate(user_params[:password])
                flash[:notice] = ""
                set_user(user)
                destination = session[:last] || "/"
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
    
end