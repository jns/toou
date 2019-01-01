require 'test_helper'

class AuthenticateTest < ActionDispatch::IntegrationTest
  
  def setup()
    # Seed test database with countries
    load "#{Rails.root}/db/seeds.rb"  
  end
  
  test "request OTP" do
    post '/api/requestOneTimePasscode', params: "{\"phoneNumber\": \"3109097243\", \"deviceId\": \"12345\"}", headers: {"Content-Type": "application/json"}
    assert_response :ok
  end
end
