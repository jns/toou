class WelcomeController < ApplicationController

    skip_before_action :authorize_admin, only: [:index, :about, :login, :authenticate]
    
    # presents the welcome screen
    def index
    end
    
    # presents the about screen
    def about
    end
    
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
    

  private
  
    def getCredentials 
      params.require([:username, :password])
    end
    
end
