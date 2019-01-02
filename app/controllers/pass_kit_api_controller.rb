
# This API is designed around fetching and updating individual passes
# That are affiliated with a specific device
class PassKitApiController < ActionController::Base
    
    include PassesHelper
    
    before_action :authorize_request, except: [:listPasses, :logError]
    
    # Registers a device to receive push notifications
    def register
        
    end
    
    # Unregisters a devcie from a pass, and push notifications are no longer sent
    def unregister
        
    end
    
    # Returns the passes associated with a device
    def listPasses
        
    end
    
    # Returns the latest version of a specific pass
    # Returns a 404 if the requested pass is not available to the authenticated user
    # Reutrns a 501 if the pass is currently unavailable and is getting recreated.  Client should try again
    def fetch
        passTypeId, serialNumber = fetch_params
        # Verfiy auth token matches passed parameters
        if @current_pass.serialNumber != serialNumber || @current_pass.passTypeIdentifier != passTypeId
            render json: {error: "mismatch"}, status: :unauthorized
            return
        end

        passFileName = passFileName(@current_pass)
        
        # If pass doesn't exist then build pass on the fly
        if not File.exists?(passFileName)
            PassBuilderJob.new().perform(@current_pass.id)
        end
        
        # If pass still doesn't exist there was an error, return not_found
        if File.exists?(passFileName)
            send_file(passFileName, type: 'application/vnd.apple.pkpass', disposition: 'inline')
        else
            render json: {}, status: :not_found
        end
    end
  
    # Endpoint for logging pkpass errors
    def logError
        
    end
    
    private
    
    attr_reader :current_pass
    
    # Decodes the token in the authorization header and sets @current_pass
    def authorize_request
        
        begin 
            auth_token = if request.headers['Authorization'].present?
                request.headers['Authorization'].split(' ').last
            end
            throw "Unauthorized 1" unless auth_token 
            
            decoded_auth_token = JsonWebToken.decode(auth_token)
            throw "Unauthorized 2" unless decoded_auth_token 

            @current_pass = Pass.find(decoded_auth_token[:pass_id])
            throw "Unauthorized 3" unless @current_pass 
        rescue => e
            render json: {error: e.message}, status: :unauthorized
        end
        
    end

    # Returns parameters required by fetch operation
    def fetch_params
      params.require([:pass_type_id, :serial_number])
    end
end
