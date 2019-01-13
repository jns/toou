
class SendDeviceNotification < ServerRequest
    
    prepend SimpleCommand
    
    
    def initialize(account)
        @account = account
    end
    
    def call
        
        unless @account.can_receive_notifications? 
            errors.add(:not_supported, "Account cannot receive device notifications")
            return
        end

        payload = {}
        payload["aps"] = {"alert": {
                            "title": "TooU Received",
                            "body": "You've received a drink."},
        }  
        
        header = {}
        header["Content-Type"] = "application/json"
        header["Authorization"] = "Bearer #{generate_token}"
        header["apns-expiration"] = (Time.now + 1.day).to_i.to_s
        header["apns-priority"] = "10"
        
        uri = URI("#{ENV["APN_SERVER"]}/3/device/#{@account.device_id}")
        response = post(uri, payload.to_json, header)
        
        case response
        when Net::HTTPOK 
            return true
        when Net::HTTPForbidden
            # problem with token
            message = "The Authentication token was rejected"
            Log.create(log_type: Log::ERROR, context: SendDeviceNotification
            .name, current_user: @account.id, message: message)
            errors.add(:remote_server_error, message)
        else
            message = "SendDeviceNotification failed with error code: #{response.code}"
            Log.create(log_type: Log::ERROR, context: SendDeviceNotification
            .name, current_user: @account.id, message: message)
            errors.add(:remote_server_error, message)
        end
    end
    
    def generate_token
        epoch  = Time.new.getutc.to_i
        headers = {"kid": "WDP9STG6UT"}
        payload = {"iss": "8Q9F954LPX", "iat": epoch }
        key = OpenSSL::PKey::EC.new File.read Rails.application.secrets.apn_key_file
        JWT.encode(payload, key, 'ES256', headers)
    end
end