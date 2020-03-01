class UserApiController < ApiBaseController
    
    skip_before_action :authorize_request, only: [:authenticate, :request_password_reset, :password_reset]
    
    # Resets the password for a user and returns the JWT for the authenticated user.
    # expects a json payload with field {token: String, new_password: String} that is the password reset token
    # returns a json payload with field {success: [true, false], auth_token: String, error: String} 
    def password_reset
        token, new_password = params.require([:token, :new_password])
        user = User.with_reset_token(token)
        if user
            user.update(password: new_password, reset_digest: nil, reset_sent_at: nil)
            render json: auth_response(user), status: :ok
        else
           render json: {success: false, error: "Invalid Token"} , status: :unauthorized
        end
    end
    
    # Requests a password reset email 
    # returns a json payload with fields {success: [true, false], error: String}
    def request_password_reset 
        email = params.require(:email)
        @user = User.find_by(email: email.downcase)
        if @user
          @user.create_reset_digest
          UserMailer.with(user: @user, url: "#{root_url}password_reset/#{@user.reset_token}").password_reset.deliver_now
          render json: {success: true}, status: :ok
        else
          render json: {success: false, error: "email not found"}, status: :bad_request
        end
    end
    
    
    # Authenticate a  user
    # @param [String] username The username
    # @param [String] password The password
    def authenticate
        begin 
            user = if params[:gtoken] # this is a google signin
                token = params[:gtoken]
                cmd = ProcessGoogleToken.call(token)
                if cmd.success?
                    cmd.result
                else
                    nil
                end
            else # Use username, password
                user_params = params.require(:data).permit(:email, :password)
                u = User.find_by(email: user_params[:email].downcase) 
                if u and u.authenticate(user_params[:password])
                    u
                else 
                    nil
                end 
            end
        
            if user 
                render json: auth_response(user), status: :ok
            else 
               render json: {error: "User not found"}, status: :unauthorized 
            end
        rescue Error => err
            puts err
            render json: {error: "Login Error"}, status: :unauthorized
        end
    end
    
    private
    
    def auth_response(user)
        token = JsonWebToken.encode(user_id: user.id, user_type: "User") 
        {success: true, auth_token: token, type: "USER", username: user.username}
    end
    
end