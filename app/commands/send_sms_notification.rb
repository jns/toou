
class SendSmsNotification
    
    prepend SimpleCommand
    
    def initialize(pass, message)
        @account = pass.account
        @message = message
    end
    
    def call
        
      phone = @account.phone_number.to_s
      if MessageSender.new.send_message(phone, @message)
        Log.create(log_type: Log::INFO, context: SendSmsNotification.name, current_user: @account.id, message: "SMS sent to #{phone}")
      else
        Log.create(log_type: Log::ERROR, context: SendSmsNotification.name, current_user: @account.id, message: "Error sending SMS to #{phone}")
      end
    end
    
end