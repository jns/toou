class ApplicationController < ActionController::Base
    
    # Add authorization 
    include Pundit
    after_action :verify_authorized
    
    rescue_from Pundit::NotAuthorizedError, :with => :record_not_found
    
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
    
    def record_not_found
        render :text => "404 Not Found", :status => 404
    end
end
