require 'test_helper'

class PassNotificationJobTest < ActiveJob::TestCase
  test "Recipient receives text" do
    pass = passes(:not_notifiable_recipient)
    assert_difference 'FakeSMS.messages.count', 1 do 
      PassNotificationJob.perform_now(pass.id)
    end
  end
  
  test "Recipient receives notification" do
    pass = passes(:notifiable_recipient)
    assert_difference 'MockApnoticConnector.notifications.count', 1 do
      PassNotificationJob.perform_now(pass.id)
    end
  end
end
