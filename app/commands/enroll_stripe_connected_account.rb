require 'net/http'

class EnrollStripeConnectedAccount
    
    STRIPE_URI = URI('http://connect.stripe.com/oauth/token')
    
    prepend SimpleCommand
    
    def initialize(merchant, code)
       @merchant = merchant
       @code = code
    end
    
    def call
        client_secret = Rails.application.secrets.stripe_api_key
        
        Net::HTTP.start(STRIPE_URI) do |http|
            http.use_ssl = true
            res = http.post2('client_secret' => client_secret, 'code' => @code, 'grant_type' => 'authorization_code')
            if res.code === 200
                data = JSON.parse(res.body)
                @merchant.stripe_id = data["stripe_user_id"]
                @merchant.save
            else
                errors.add(:enrollment_error, "Error enrolling user")
            end
        end
        
    end
end