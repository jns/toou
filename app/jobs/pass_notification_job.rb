class PassNotificationJob < ApplicationJob
  queue_as :default

  def perform(*passes)
    passes.each do |pass_id|
      pass = Pass.find(pass_id)
      acct = pass.account
        if acct.can_receive_notifications?
            SendDeviceNotification.call(acct) unless acct.test_user?
        else
          SendSmsNotification.call(pass) unless acct.test_user?
        end
      end
  end
end
