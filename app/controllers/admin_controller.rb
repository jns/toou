class AdminController < ApplicationController

    skip_before_action :validate_auth_token, only: [:login, :authenticate, :logout]
    
    def index
    end

    # presents the login screen
    def login
    end
    
    # resets the session and redirects to home
    def logout
        reset_session
        redirect_to controller: "welcome", action: "index"
    end
    
    def restricted
    end
    
    # Authenticates the admin 
    def authenticate
        
        skip_authorization
        
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
    

  private
  
    def getCredentials 
      params.require([:username, :password])
    end
    
end
