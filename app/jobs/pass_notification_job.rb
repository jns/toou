class PassNotificationJob < ApplicationJob
  queue_as :default

  def perform(*passes)
    passes.each do |pass_id|
      begin
        pass = Pass.find(pass_id)
        recipient = pass.recipient
        
        return if recipient.is_a? Group
        
        product = pass.buyable.name.downcase
        sender = pass.purchaser.name.to_s
        if recipient.can_receive_notifications?
            title = "You've received a #{product}"
            message = "#{sender} says #{pass.message}"
            SendDeviceNotification.call(recipient, title, message) unless recipient.test_user?
        else
          message = "Hi. #{sender} just sent you a #{product} with the message \"#{pass.message}\". Visit https://www.toou.gifts/passes to get your #{product}."
          SendSmsNotification.call(recipient, message) unless recipient.test_user?
        end
      rescue ActiveRecord::RecordNotFound
        Log.create(log_type: Log::ERROR, context: "PassNotificationJob", current_user: pass_id, message: "Unable to send notification. Pass Not Found #{pass_id}")
      end
    end
  end
end
