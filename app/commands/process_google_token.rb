
class ProcessGoogleToken
   
   prepend SimpleCommand 
   
   @@keys = nil
   @@expires = nil
   
   def initialize(token)
      @token = token 
   end
   
   # Processes a gsignin token as defined in 
   # https://developers.google.com/identity/sign-in/web/backend-auth
   def call
       
        now = Time.new
        unless @@keys and @@expires and now < @@expires
            response = Net::HTTP.get_response(URI("https://www.googleapis.com/oauth2/v3/certs"))
            @@keys = JSON.parse(response.body).deep_symbolize_keys!
            max_age = response.fetch("cache-control").match(/max-age=(\d+)/)
            @@expires = now + max_age[1].to_i - 60 # 60 second grace period
        end
        
        puts @@keys
        
        begin
            decoded_token = JWT.decode @token, nil, true, { algorithm: 'RS256', jwks: @@keys }
            payload = decoded_token[0].deep_symbolize_keys!
         
            unless ENV['GOOGLE_SIGNIN_CLIENT_ID'] === payload[:aud]
                errors.add(:client_id, "Invalid client id")
            end
            
            unless payload[:iss] == "accounts.google.com" || payload[:iss] == "https://accounts.google.com"
                errors.add(:issuer, "Invalid issuer") 
            end
            
            unless payload[:exp] > Time.new.to_i
                errors.add(:expired, "Token expired") 
            end
            
            user = User.find_or_create_by(email: payload[:email].downcase)
            user.roles << Role.merchant unless user.merchant?
            user.update(username: payload[:email], first_name: payload[:given_name], last_name: payload[:family_name], picture_url: payload[:picture], locale: payload[:locale])
            return user
        rescue JWT::JWKError => e
            errors.add(:jwkError, e)
        rescue JWT::DecodeError => e
            errors.add(:decodeError, e)
        end
       
        return nil
   end
    
end