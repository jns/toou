class PassNotificationJob < ApplicationJob
  queue_as :default

  def perform(*passes)
    passes.each do |pass_id|
      begin
        pass = Pass.find(pass_id)
        acct = pass.account
        product = pass.buyable.name.downcase
        sender = pass.purchaser.name.to_s
        if acct.can_receive_notifications?
            title = "You've received a #{product}"
            message = "#{sender} says #{pass.message}"
            SendDeviceNotification.call(acct, title, message) unless acct.test_user?
        else
          message = "Hi. #{sender} just sent you a #{product} with the message \"#{pass.message}\". Visit https://toou.gifts/passes to get your #{product}."
          SendSmsNotification.call(acct, message) unless acct.test_user?
        end
      rescue ActiveRecord::RecordNotFound
        Log.create(log_type: Log::ERROR, context: "PassNotificationJob", current_user: pass_id, message: "Unable to send notification. Pass Not Found #{pass_id}")
      end
    end
  end
end
