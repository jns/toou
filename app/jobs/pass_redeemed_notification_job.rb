class PassRedeemedNotificationJob < ApplicationJob
  queue_as :default

  def perform(*passes)
    passes.each do |pass_id|
      pass = Pass.find(pass_id)
      acct = pass.account
      product = pass.buyable.name.downcase
      receiver = pass.receiver
      sender = pass.purchaser
      message = "Hooray! #{receiver.name.to_s} just used the TooU you sent them for a #{product}"
      if acct.can_receive_notifications?
          SendDeviceNotification.call(sender, message) unless sender.test_user?
      else
        SendSmsNotification.call(sender, message) unless sender.test_user?
      end  
    end
  end
end
