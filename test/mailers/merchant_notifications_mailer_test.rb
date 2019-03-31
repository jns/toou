require 'test_helper'

class MerchantNotificationsMailerTest < ActionMailer::TestCase
  test "passcode" do
    mail = MerchantNotificationsMailer.passcode
    assert_equal "Passcode", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
