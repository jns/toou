
class SendSmsNotification
    
    prepend SimpleCommand
    
    def initialize(pass)
        @sender = pass.purchaser.phone_number.to_s
        @account = pass.account
    end
    
    def call
        
      message = "Hi.  You've got a drink waiting for you at TooU courtesy of #{@sender}.  Download the app at https://toou.gifts to get your drink."
      phone = @account.phone_number.to_s
      if MessageSender.new.send_message(phone, message)
        Log.create(log_type: Log::INFO, context: SendSmsNotification.name, current_user: @account.id, message: "SMS sent to #{phone}")
      else
        Log.create(log_type: Log::ERROR, context: SendSmsNotification.name, current_user: @account.id, message: "Error sending SMS to #{phone}")
      end
    end
    
end