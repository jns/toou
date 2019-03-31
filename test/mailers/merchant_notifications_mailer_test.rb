require 'test_helper'

class MerchantNotificationsMailerTest < ActionMailer::TestCase
  test "passcode" do
    u = users(:quantum_user)
    otp = u.generate_otp_for_device("test_device")
    mail = MerchantNotificationsMailer.with(user: u, passcode: otp).passcode_email
    assert_match "Passcode", mail.subject
    assert_equal [u.email], mail.to
    assert_equal ["support@toou.gifts"], mail.from
    assert_match otp, mail.body.encoded
  end

end
