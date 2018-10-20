require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest

  def setup
    @acct1 = Account.find(1)
    @acct1.generate_otp
    @devId = "12345"
  end

  # test "the truth" do
  #   assert true
  # end
  test "Request OTP" do

    post "/api/requestOneTimePasscode", params: {"phoneNumber": @acct1.mobile, "deviceId": @devId}, as: :json
    assert_response :success
    
    assert_equal 1, MessageSender.client.messages.size
    
  end
  
  test "Creates a new account" do
    number = "555-555-5555"
    assert_nil Account.find_by_mobile(number)
    
    post "/api/requestOneTimePasscode", params: {"phoneNumber": number, "deviceId": @devId}, as: :json
    assert_response :success
    
    assert_not_nil Account.find_by_mobile(number)
  end
  
  
  test "Authentication Succeeds" do

    post "/api/authenticate", params: {"phoneNumber": @acct1.mobile, "passCode": @acct1.one_time_password_hash, "deviceId": @devId}, as: :json  
    
    assert_response :success
    json = JSON.parse(@response.body) 
    assert_not_nil json["auth_token"]
  end
  
  test "Authentication Fails" do
    bad_otp = @acct1.one_time_password_hash + "1"
    post "/api/authenticate", params: {"phoneNumber": @acct1.mobile, "passCode": bad_otp, "deviceId": @devId}, as: :json  
    
    assert_response :unauthorized
  end
  
  test "Fetch Passes" do
    
    post "/api/authenticate", params: {"phoneNumber": @acct1.mobile, "passCode": @acct1.one_time_password_hash, "deviceId": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
    
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}
    passes = JSON.parse(@response.body)
    assert_equal 2, passes.size
    
  end
  
  test "Fetch Passes unauthorized" do
    
    token = "ThisIs.NotA.Token"
    
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}
    passes = JSON.parse(@response.body)
    assert_response :unauthorized
    
  end
  
  
end
