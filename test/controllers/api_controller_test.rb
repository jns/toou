require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest

  include ActionView::Helpers::NumberHelper

  def setup
    # Seed test database with countries
    #load "#{Rails.root}/db/seeds.rb"
    
    @acct1 = Account.find(1)
    @acct1_passcode = @acct1.generate_otp
    @devId = "12345"
    
    @acct2 = Account.find(2)
    @acct2_passcode = @acct2.generate_otp
    
    @acct3 = Account.find(3)
    @acct3_passcode = @acct3.generate_otp
    
    # Don't throw errors from the SMS client
    FakeSMS.throw_error = nil
  end


  test "Fetch products" do 
    get "/api/products"
    assert_response :success
    
    assert_equal Product.count, JSON.parse(response.body).size 
  end

  # test "the truth" do
  #   assert true
  # end
  test "Request OTP" do

    MessageSender.client.messages.clear
    
    post "/api/requestOneTimePasscode", params: {"phone_number": number_to_phone(@acct1.phone_number.to_s), "device_id": @devId}, as: :json
    assert_response :success
    
    # Disabled SMS for now
    # assert_equal 1, MessageSender.client.messages.size
    
    # Temporarily return passcode inside response
    json = JSON.parse(@response.body)
    assert_not_nil(json["passcode"])
    
  end
  
  test "Creates a new account" do
    number = "(555) 555-5555"
    assert_nil Account.search_by_phone_number(number)
    
    post "/api/requestOneTimePasscode", params: {"phone_number": number, "device_id": @devId}, as: :json
    assert_response :success
        
    acct = Account.search_by_phone_number(number)
    assert_not_nil acct
    assert_equal @devId, acct.device_id
  end
  
  test "Creates an account without a device id" do
    number = "(555) 555-5556"
    assert_nil Account.search_by_phone_number(number)
    
    post "/api/requestOneTimePasscode", params: {"phone_number": number}, as: :json
    assert_response :success
    
    acct = Account.search_by_phone_number(number)
    assert_not_nil acct
    assert_nil acct.device_id
  end
  
  test "Creates an account without an empty device id" do
    number = "(555) 555-5556"
    assert_nil Account.search_by_phone_number(number)
    
    post "/api/requestOneTimePasscode", params: {"phone_number": number, "device_id": ""}, as: :json
    assert_response :success
    
    acct = Account.search_by_phone_number(number)
    assert_not_nil acct
    assert_nil acct.device_id
  end
  
  test "Catches Error" do
    FakeSMS.throw_error = "Testing Error"
    
    number = "(555) 555-5557"
    assert_nil Account.search_by_phone_number(number)
    
    post "/api/requestOneTimePasscode", params: {"phone_number": number, "device_id": ""}, as: :json
    assert_response :internal_server_error
    
    log_entry = Log.last
    assert log_entry.message.index(FakeSMS.throw_error)
    
  end
  
  test "Authentication Succeeds" do
    post "/api/authenticate", params: {"phone_number": @acct1.phone_number.to_s, "pass_code": @acct1_passcode, "device_id": @devId}, as: :json  
    
    assert_response :success
    json = JSON.parse(@response.body) 
    assert_not_nil json["auth_token"]
  end
  
  test "Authenticate without deviceid" do
    post "/api/authenticate", params: {"phone_number": @acct1.phone_number.to_s, "pass_code": @acct1_passcode, "device_id": ""}, as: :json  
    
    assert_response :success
    json = JSON.parse(@response.body) 
    assert_not_nil json["auth_token"]
  end
  
  test "Authentication Fails" do
    bad_otp = "not a passcode"
    post "/api/authenticate", params: {"phone_number": @acct1.phone_number.to_s, "pass_code": bad_otp, "device_id": @devId}, as: :json  
    
    assert_response :unauthorized
  end
  
  test "Fetch Passes" do
    
    post "/api/authenticate", params: {"phone_number": @acct1.phone_number.to_s, "pass_code": @acct1_passcode, "device_id": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
    
    # Posting with no parameters will return only valid passes
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}
    passes = JSON.parse(@response.body)
    assert_equal 1, passes.size
    assert_equal "abc124", passes.first["serialNumber"]
    
    assert_equal ["phone_number", "email"], passes.first["purchaser"].keys
    
    assert_equal @acct2.phone_number.to_s, passes.first["purchaser"]["phone_number"]
    assert_equal @acct2.email, passes.first["purchaser"]["email"]
    
  
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}, params: {"serialNumbers": ["abc123", "abc124"]}
    passes = JSON.parse(@response.body)
    
    assert_equal 2, passes.size
    assert_equal "EXPIRED", passes.find{|p| p["serialNumber"] == "abc123"}["status"]
    assert_equal "VALID", passes.find{|p| p["serialNumber"] == "abc124"}["status"]
    
  end
  
  test "Fetch a pass with an emoji" do
    post "/api/authenticate", params: {"phone_number": @acct3.phone_number.to_s, "pass_code": @acct3_passcode, "device_id": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
    
    # Posting with no parameters will return valid passes
    post "/api/passes", headers: {"Authorization": "Bearer #{token}"}
    passes = JSON.parse(@response.body)
    assert_equal 1, passes.size
    assert_equal "This pass has an emoji \u{1F44D}", passes.first["message"]
  
  end
  
  test "Fetch Invalid Pass" do
  
    post "/api/authenticate", params: {"phone_number": @acct1.phone_number.to_s, "pass_code": @acct1_passcode, "device_id": @devId}, as: :json  
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
    
    post "/api/authenticate", params: {"phone_number": @acct1.phone_number.to_s, "pass_code": @acct1_passcode, "device_id": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/place_order", headers: {"Authorization": "Bearer #{token}"}, 
      params: {"recipients": [@acct1.phone_number.to_s],
               "message": "So Long and Thanks for all the Fish",
               "payment_source": "mock_payment_source_token",
               "product": {"id": products(:beer).id, "type": "Product"}}
    
    assert_response :success
    order = JSON.parse(@response.body)
    assert order["order_id"].to_i > 0
    
  end
  
  test "Place Order Unauthorized" do 
     
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/place_order", headers: {"Authorization": "Bearer Not.A.Token"}, 
      params: {"recipients": ["310-909-7243","5043834228"],
               "message": "So Long and Thanks for all the Fish", 
               "product": {"id": promotions(:generic).id, "type": "Promotion"}
      }
    
    assert_response :unauthorized
  end
  
  test "Account History Succeeds" do
    post "/api/authenticate", params: {"phone_number": @acct2.phone_number.to_s, "pass_code": @acct2_passcode, "device_id": @devId}, as: :json  
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
    
    post "/api/authenticate", params: {"phone_number": @acct1.phone_number.to_s, "pass_code": @acct1_passcode, "device_id": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    pass = passes(:distant_future)
  
    get "/api/pass/#{pass.serialNumber}", headers: {"Authorization": token}
    assert_response :ok
  end
  
  
  test "Fetch another users apple pkpass - Not Found" do
    
    post "/api/authenticate", params: {"phone_number": @acct2.phone_number.to_s, "pass_code": @acct2_passcode, "device_id": @devId}, as: :json  
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
  
  test "Merchant can redeem a pass" do
    pass = passes(:redeemable_pass)
    merchant = merchants(:quantum)
    payload = {merchant_id: merchant.id}
    token = JsonWebToken.encode(payload)
    
    post "/api/redeem", params: {authorization: token, pass: {serial_number: pass.serialNumber}}
    assert_response :ok
    
    pass = Pass.find(pass.id)
    assert pass.used?
  end
  
  test "Redeem a used pass returns bad request and generates no charge" do
    pass = passes(:used_beer_pass)
    merchant = merchants(:quantum)
    payload = {merchant_id: merchant.id}
    token = JsonWebToken.encode(payload)
    
    assert_no_difference 'Charge.count' do
      post "/api/redeem", params: {authorization: token, pass: {serial_number: pass.serialNumber}}
      assert_response :bad_request
    end
  end
  
  test "Merchant credits endpoint returns charges credited to merchant" do
    merchant = merchants(:quantum)
    payload = {merchant_id: merchant.id}
    token = JsonWebToken.encode(payload)
    post "/api/credits", params: {authorization: token}
    assert_response :ok
    credits = JSON.parse(response.body)
    assert_equal 1, credits.size
  end
end
