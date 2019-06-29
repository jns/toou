require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "password reset" do
    u = users(:quantum_user)
    u.create_reset_digest
    mail = UserMailer.with(user: u, url: "https://example.com/password_reset/#{u.reset_token}").password_reset
    assert_match "Password Reset", mail.subject
    assert_equal [u.email], mail.to
    assert_equal ["support@toou.gifts"], mail.from
    assert_match u.reset_token, mail.body.encoded
  end

end
