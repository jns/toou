class UserApiController < ApiBaseController
    
    skip_before_action :authorize_request, only: [:authenticate, :request_password_reset, :password_reset, :create_merchant_account]
    
    def get_user 
       render json: {email: @current_user.email, username: @current_user.username}, status: :ok
    end
    
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
        @user = EmailAccount.find_by(email: email.downcase)
        if @user
          @user.create_reset_digest
          UserMailer.with(user: @user, url: "#{root_url}password_reset/#{@user.reset_token}").password_reset.deliver_now
          render json: {success: true}, status: :ok
        else
          render json: {success: false, error: "email not found"}, status: :bad_request
        end
    end
    
    def create_merchant_account
        data = params.require(:data).permit([:email, :password])
        email = data.require(:email).downcase
        password = data.require(:password)
        @user = EmailAccount.find_by(email: email)
        if @user
            render json: {success: false, error: "User already exists"}, status: :bad_request
        else
            username = email
            user = User.create(username: username, email: email)
            user.accounts << EmailAccount.create(email: email, password: password)
            if user
                user.roles << Role.merchant
                render json: auth_response(user), status: :ok
            else
                render json: {success: false, error: "Error creating account"}, status: :internal_server_error 
            end 
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
            elsif params[:data][:email] and params[:data][:password] # Use username, password
                user_params = params.require(:data).permit(:email, :password)
                email, password = user_params.require([:email, :password])
                acct = EmailAccount.find_by(email: email.downcase) 
                if acct and acct.authenticate(password)
                    acct.user
                else 
                    nil
                end 
            elsif params[:pass_code] and params[:phone_number]
                user_params = params.require(:data).permit(:pass_code, :phone_number)
                otp, phone_number = user_params.require([:pass_code, :phone_number])
                command = AuthenticateUser.call(phoneNumber, otp)
        
                if command.success?
                    command.result.user
                else
                    nil
                end
            else 
                nil
            end
        
            if user 
                render json: auth_response(user), status: :ok
            else 
               render json: {error: "Email or Password not found or is incorrect"}, status: :unauthorized 
            end
        rescue Error => err
            puts err
            render json: {error: "Login Error"}, status: :unauthorized
        end
    end
    
    private
    
    def auth_response(user)
        token = JsonWebToken.encode(user_id: user.id, user_type: "User") 
        email = user.first_email
        {success: true, auth_token: token, type: "USER", username: user.username, email: email}
    end
    
end