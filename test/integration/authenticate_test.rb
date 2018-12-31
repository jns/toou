require 'test_helper'

class AuthenticateTest < ActionDispatch::IntegrationTest
  
  test "request OTP" do
    post '/api/requestOneTimePasscode', params: "{\"phoneNumber\": \"3109097243\", \"deviceId\": \"12345\"}", headers: {"Content-Type": "application/json"}
    assert_response :ok
  end
end
