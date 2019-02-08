require 'net/http'

class EnrollStripeConnectedAccount
    
    STRIPE_URI = URI('https://connect.stripe.com/oauth/token')
    
    prepend SimpleCommand
    
    def initialize(merchant, code)
       @merchant = merchant
       @code = code
    end
    
    def call
        client_secret = Rails.application.secrets.stripe_api_key
        
        req = Net::HTTP::Post.new(STRIPE_URI)
        req.set_form_data('client_secret' => client_secret, 'code' => @code, 'grant_type' => 'authorization_code')
        res = Net::HTTP.start(STRIPE_URI.host, STRIPE_URI.port, :use_ssl => true) do |http|
            res = http.request(req)
        end
        case res
        when Net::HTTPSuccess
            data = JSON.parse(res.body)
            @merchant.stripe_id = data["stripe_user_id"]
            @merchant.save
        else
            errors.add(:enrollment_error, "Error enrolling user " + res.value)
        end
    end
end