require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest

  include ActionView::Helpers::NumberHelper

  def setup
    # Seed test database with countries
    #load "#{Rails.root}/db/seeds.rb"
    
    @acct1 = Account.find(1)
    @acct1.generate_otp
    @devId = "12345"
    
    @acct2 = Account.find(2)
    @acct2.generate_otp
    
    @acct3 = Account.find(3)
    @acct3.generate_otp
  end

  # test "the truth" do
  #   assert true
  # end
  test "Request OTP" do

    MessageSender.client.messages.clear
    
    post "/api/requestOneTimePasscode", params: {"phone_number": number_to_phone(@acct1.primary_phone_number.to_s), "name": @acct1.name, "device_id": @devId}, as: :json
    assert_response :success
    
    # Disabled SMS for now
    # assert_equal 1, MessageSender.client.messages.size
    
    # Temporarily return passcode inside response
    json = JSON.parse(@response.body)
    assert_not_nil(json["passcode"])
    
  end
  
  test "Creates a new account" do
    number = "(555) 555-5555"
    assert_nil PhoneNumber.find_by_string(number)
    
    post "/api/requestOneTimePasscode", params: {"phone_number": number, "name": "Name", "device_id": @devId}, as: :json
    assert_response :success
    
    assert_not_nil Account.find_by_mobile(number)
  end
  
  
  test "Authentication Succeeds" do

    post "/api/authenticate", params: {"phoneNumber": @acct1.primary_phone_number.to_s, "passCode": @acct1.one_time_password_hash, "deviceId": @devId}, as: :json  
    
    assert_response :success
    json = JSON.parse(@response.body) 
    assert_not_nil json["auth_token"]
  end
  
  test "Authentication Fails" do
    bad_otp = @acct1.one_time_password_hash + "1"
    post "/api/authenticate", params: {"phoneNumber": @acct1.primary_phone_number.to_s, "passCode": bad_otp, "deviceId": @devId}, as: :json  
    
    assert_response :unauthorized
  end
  
  test "Fetch Passes" do
    
    post "/api/authenticate", params: {"phoneNumber": @acct1.primary_phone_number.to_s, "passCode": @acct1.one_time_password_hash, "deviceId": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
    
    # Posting with no parameters will return only valid passes
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}
    passes = JSON.parse(@response.body)
    assert_equal 1, passes.size
    assert_equal "abc124", passes.first["serialNumber"]
    
    assert_equal ["name", "mobile", "email"], passes.first["purchaser"].keys
    
    assert_equal @acct2.name, passes.first["purchaser"]["name"]
    assert_equal @acct2.primary_phone_number.to_s, passes.first["purchaser"]["mobile"]
    assert_equal @acct2.email, passes.first["purchaser"]["email"]
    
  
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}, params: {"serialNumbers": ["abc123", "abc124"]}
    passes = JSON.parse(@response.body)
    
    assert_equal 2, passes.size
    assert_equal "EXPIRED", passes.find{|p| p["serialNumber"] == "abc123"}["status"]
    assert_equal "VALID", passes.find{|p| p["serialNumber"] == "abc124"}["status"]
    
  end
  
  test "Fetch a pass with an emoji" do
    post "/api/authenticate", params: {"phoneNumber": @acct3.primary_phone_number.to_s, "passCode": @acct3.one_time_password_hash, "deviceId": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
    
    # Posting with no parameters will return valid passes
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}
    passes = JSON.parse(@response.body)
    assert_equal 1, passes.size
    assert_equal "This pass has an emoji \u{1F44D}", passes.first["message"]
  
  end
  
  test "Fetch Invalid Pass" do
  
    post "/api/authenticate", params: {"phoneNumber": @acct1.primary_phone_number.to_s, "passCode": @acct1.one_time_password_hash, "deviceId": @devId}, as: :json  
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
    body = JSON.parse(@response.body)
    assert_response :unauthorized
    assert_not_nil(body["error"])
    
  end
  
  test "Place Order Succeeds" do
    
    post "/api/authenticate", params: {"phoneNumber": @acct1.primary_phone_number.to_s, "passCode": @acct1.one_time_password_hash, "deviceId": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/place_order", headers: {"Authorization": "Bearer #{token}"}, 
      params: {"recipients": [{"phoneNumber" => @acct1.primary_phone_number.to_s}],
               "message": "So Long and Thanks for all the Fish"
      }
    
    assert_response :success
    order = JSON.parse(@response.body)
    assert order["order_id"].to_i > 0
    
  end
  
  test "Place Order Unauthorized" do 
     
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/place_order", headers: {"Authorization": "Bearer Not.A.Token"}, 
      params: {"recipients": [{"phoneNumber" => "310-909-7243"}, 
                              {"phoneNumber" =>  "5043834228"}],
               "message": "So Long and Thanks for all the Fish"
      }
    
    assert_response :unauthorized
  end
  
  test "Account History Succeeds" do
    post "/api/authenticate", params: {"phoneNumber": @acct2.primary_phone_number.to_s, "passCode": @acct2.one_time_password_hash, "deviceId": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/history", headers: {"Authorization": "Bearer #{token}"}
    assert_response :success
    history = JSON.parse(@response.body)
    assert history.size == 3
    
    assert_equal ["date", "activity_type", "message"], history.first.keys
  end
  
  test "Account History Unauthorized" do
    
    post "/api/history", headers: {"Authorization": "Bearer Not.A.Token"}
    assert_response :unauthorized
    
  end
  
  test "Fetch an apple pkpass - Authorized" do
    
    post "/api/authenticate", params: {"phoneNumber": @acct1.primary_phone_number.to_s, "passCode": @acct1.one_time_password_hash, "deviceId": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    pass = passes(:distant_future)
  
    get "/api/pass/#{pass.serialNumber}", headers: {"Authorization": token}
    assert_response :ok
  end
  
  
  test "Fetch another users apple pkpass - Not Found" do
    
    post "/api/authenticate", params: {"phoneNumber": @acct2.primary_phone_number.to_s, "passCode": @acct2.one_time_password_hash, "deviceId": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    pass = passes(:distant_future)
  
    get "/api/pass/#{pass.serialNumber}", headers: {"Authorization": token}
    assert_response :not_found
  end
  
  test "Fetch an apple pkpass - Unuthorized" do
    pass = passes(:distant_future)
    get "/api/pass/#{pass.serialNumber}"
    assert_response :unauthorized
  end
  
end
