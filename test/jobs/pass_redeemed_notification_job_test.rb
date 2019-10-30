require 'test_helper'

class PassRedeemedNotificationJobTest < ActiveJob::TestCase
  
  test "Purchaser receives text" do
    pass = passes(:not_notifiable_purchaser)
    assert_difference 'FakeSMS.messages.count', 1 do 
      PassRedeemedNotificationJob.perform_now(pass.id)
    end
  end
  
  test "Purchaser receives notification" do
    pass = passes(:notifiable_purchaser)
    assert_difference 'MockApnoticConnector.notifications.count', 1 do
      PassRedeemedNotificationJob.perform_now(pass.id)
    end
  end
end
