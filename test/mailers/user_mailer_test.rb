require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "password reset" do
    a = accounts(:quantum)
    a.create_reset_digest
    mail = UserMailer.with(account: a, url: "https://example.com/password_reset/#{a.reset_token}").password_reset
    assert_match "Password Reset", mail.subject
    assert_equal [a.email], mail.to
    assert_equal ["support@toou.gifts"], mail.from
    assert_match a.reset_token, mail.body.encoded
  end

end
