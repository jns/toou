class UserApiController < ApiBaseController
    
    skip_before_action :authorize_request, only: [:authenticate]
    
    
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
                user_params = params.require(:data).permit(:username, :password)
                u = User.find_by(username: user_params[:username].downcase) 
                if u and u.authenticate(user_params[:password])
                    u
                else 
                    nil
                end 
            end
        
            if user 
                token = JsonWebToken.encode(user_id: user.id, user_type: "User") 
                render json: {auth_token: token, type: "USER"}, status: :ok
            else 
               render json: {error: "User not found"}, status: :unauthorized 
            end
        rescue Error => err
            puts err
            render json: {error: "Login Error"}, status: :unauthorized
        end
    end
    
end