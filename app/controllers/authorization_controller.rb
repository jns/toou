class AuthorizationController < ApplicationController

    helper OpenIconicHelper
    
    before_action :authorize_admin, except: [:login, :authenticate]
    
    # presents the login screen
    def login
    end
    
    # resets the session and redirects to home
    def logout
        reset_session
        redirect_to root_url
    end
    
    # Authenticates the admin 
    def authenticate
        username, password = getCredentials
        command = AuthenticateAdmin.call(username, password)
    
       if command.success?
           session["auth_token"] = command.result
           redirect_to action: :restricted
       else
            session["auth_token"] = nil
            flash[:notice] = "Login unsuccessful"
            redirect_to '/admin/login'
       end
    end
    
    def restricted
    end
    
    private
    
    attr_reader :current_user

    def authorize_admin
        
        decoded_auth_token ||= JsonWebToken.decode(session["auth_token"])
        user ||= AdminAccount.find(decoded_auth_token[:user_id]) if decoded_auth_token
    
        if user 
            @current_user = user
        else
            flash[:notice] = "Invalid Credentials"
            redirect_to '/admin/login'
        end
    end
    
    
    def getCredentials 
      params.require([:username, :password])
    end
end
