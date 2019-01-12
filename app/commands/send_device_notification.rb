require 'net/https'

class SendDeviceNotification
    
    cattr_reader :notifications
    prepend SimpleCommand
    
    @@notifications = []
    
    def initialize(pass)
        @pass = pass
    end
    
    def call
        
        sender = @pass.purchaser.phone_numbers
        
        payload = {}
        payload["aps"] = {"alert": {
                            "title": "TooU Drink Received",
                            "subtitle": "You've got a drink",
                            "body": "You've received a drink from #{from}"},
                        "pass_id": @pass.id
        }  
        
        header = {}
        header["Authorization"] = "Bearer #{generate_token}"
        
        path = URI.new(ENV["APN_SERVER"] + "/3/device/#{device_token}")
        response = Net::HTTP.post(path, payload, header)
        response.code
    end
    
    def generate_token
        epoch  = Time.new.getutc.to_i
        headers = {"kid": "WDP9STG6UT"}
        payload = {"iss": "", "iat": epoch }
        
        JWT.encode(payload, Rails.application.secrets.apn_key, 'ES256', headers)
    end
end