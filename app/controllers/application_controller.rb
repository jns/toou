class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    before_action :validate_auth_token

    private
    
    attr_reader :current_user

    def validate_auth_token
        
        decoded_auth_token ||= JsonWebToken.decode(session["auth_token"])
        user ||= AdminAccount.find(decoded_auth_token[:user_id]) if decoded_auth_token
    
        if user 
            @current_user = user
        else
            flash[:notice] = "Invalid Credentials"
            redirect_to '/admin/login'
        end
    end
    
    
end
