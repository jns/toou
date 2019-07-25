class ApplicationController < ActionController::Base
    
    # Add authorization 
    include Pundit
    #after_action :verify_authorized
    
    rescue_from Pundit::NotAuthorizedError, :with => :record_not_found
    rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
    
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    #before_action :validate_auth_token
    before_action :set_user
    
    
    private
    
    attr_reader :current_user

    def validate_auth_token
        
        decoded_auth_token ||= JsonWebToken.decode(session["auth_token"])
        user ||= AdminAccount.find(decoded_auth_token[:user_id]) if decoded_auth_token
    
        if user 
            @current_user = user
        else
            flash[:notice] = "Invalid Credentials"
            redirect_to login_url
        end
    end
    
    def set_user(user = nil)
        session[:last] = session[:current]
        session[:current] = request.fullpath
        if user
            session[:user_id] = user.id
        elsif session[:user_id]
            begin
                @current_user = User.find(session[:user_id])
            rescue ActiveRecord::RecordNotFound
                reset_session
                @current_user = nil
            end
        else
            redirect_to login_url
        end
    end
    
    def record_not_found
        render file: File.join(Rails.root, "public", "404.html"), :status => 404
    end
end
