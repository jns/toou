class PassNotificationJob < ApplicationJob
  queue_as :default

  def perform(*passes)
    passes.each do |pass_id|
      pass = Pass.find(pass_id)
      acct = pass.account
      product = pass.buyable.name.downcase
      sender = pass.purchaser.name.to_s
      if acct.can_receive_notifications?
          message = "You've received a #{product} from #{sender}"
          SendDeviceNotification.call(acct, message) unless acct.test_user?
      else
        message = "Hi.You've got a #{product} waiting for you at TooU courtesy of #{sender}.  Visit https://toou.gifts to get your drink."
        SendSmsNotification.call(acct, message) unless acct.test_user?
      end
    end
  end
end
