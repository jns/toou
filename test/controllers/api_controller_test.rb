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

    MessageSender.client.messages.clear
    
    post "/api/requestOneTimePasscode", params: {"phoneNumber": @acct1.mobile, "deviceId": @devId}, as: :json
    assert_response :success
    
    # Disabled SMS for now
    # assert_equal 1, MessageSender.client.messages.size
    
    # Temporarily return passcode inside response
    json = JSON.parse(@response.body)
    assert_not_nil(json["passcode"])
    
  end
  
  test "Creates a new account" do
    number = "5555555555"
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
    
    # Posting with no parameters will return valid passes
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}
    passes = JSON.parse(@response.body)
    assert_equal 1, passes.size
    assert_equal "abc124", passes.first["serialNumber"]
  
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}, params: {"serialNumbers": ["abc123", "abc124"]}
    passes = JSON.parse(@response.body)
    
    assert_equal 2, passes.size
    assert_equal "EXPIRED", passes.find{|p| p["serialNumber"] == "abc123"}["status"]
    assert_equal "VALID", passes.find{|p| p["serialNumber"] == "abc124"}["status"]
    
  end
  
  test "Fetch Invalid Pass" do
  
    post "/api/authenticate", params: {"phoneNumber": @acct1.mobile, "passCode": @acct1.one_time_password_hash, "deviceId": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}, params: {"serialNumbers": ["12345abc"]}
    passes = JSON.parse(@response.body)
    
    assert_equal 2, passes.size
    assert_equal "INVALID", passes.find{|p| p["serialNumber"] == "12345abc"}["status"]
    
  end
  
  
  test "Fetch Passes unauthorized" do
    
    token = "ThisIs.NotA.Token"
    
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}, params: {"serialNumbers": ["abc123", "abc124"]}
    passes = JSON.parse(@response.body)
    assert_response :unauthorized
    
  end
  
  
end
