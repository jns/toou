class PassNotificationJob < ApplicationJob
  queue_as :default

  def perform(*passes)
    passes.each do |pass_id|
      pass = Pass.find(pass_id)
      acct = pass.account
        if acct.can_receive_notifications?
            SendDeviceNotification.call(acct)
        else
          SendSmsNotification.call(pass)
        end
      end
  end
end
