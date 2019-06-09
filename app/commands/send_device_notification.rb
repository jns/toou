
class SendDeviceNotification
    
    prepend SimpleCommand
    cattr_accessor :connector
    @@connector = Apnotic::Connection
    
    def initialize(account)
        @account = account
    end
    
    def call
        
        unless @account.can_receive_notifications? 
            errors.add(:not_supported, "Account cannot receive device notifications")
            return
        end

        # create a persistent connection
        connection = @@connector.new(url: ENV["APN_SERVER"],
            auth_method: :token,
            cert_path: S3_BUCKET.object(Rails.application.secrets.apn_key_file).get.body,
            key_id: "WDP9STG6UT",
            team_id: "8Q9F954LPX")
        
        # create a notification for a specific device token
        token = @account.device_id
        
        notification       = Apnotic::Notification.new(token)
        notification.alert = "You've receive a drink from TooU!"
        notification.expiration = (Time.now + 1.day).to_i.to_s
        notification.priority = 10
        notification.topic = "gifts.toou.TooU"
        # notification.authorization = generate_token
        
        # send (this is a blocking call)
        response = connection.push(notification)
    
        # close the connection
        connection.close

        if response.ok?
            message = "APN Notification Sent"
            Log.create(log_type: Log::INFO, context: SendDeviceNotification.name, current_user: @account.id, message: message)
            return true
        else
            # problem with token
            message = "APN Server Error #{response.status}: #{response.body}"
            Log.create(log_type: Log::ERROR, context: SendDeviceNotification.name, current_user: @account.id, message: message)
            #@TODO re-schedule for later execution
            return false
            # errors.add(:remote_server_error, message)     
        end
    end
    
end