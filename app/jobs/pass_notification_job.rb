class PassNotificationJob < ApplicationJob
  queue_as :default

  def perform(*passes)
    passes.each do |pass_id|
      acct = Pass.find(pass_id).account
        if acct.can_receive_notifications?
            SendDeviceNotification.call(acct)
        else
          pass = Pass.find(pass_id)
          SendRedemptionCode.call(pass)
        end
      end
  end
end
