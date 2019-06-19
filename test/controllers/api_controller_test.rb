require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest

  include ActionView::Helpers::NumberHelper

  def setup
    # Seed test database with countries
    #load "#{Rails.root}/db/seeds.rb"
    
    @acct1 = accounts(:josh)
    @acct1_passcode = @acct1.generate_otp
    @devId = "12345"
    
    @acct2 = accounts(:pete)
    @acct2_passcode = @acct2.generate_otp
    
    @acct3 = accounts(:three)
    @acct3_passcode = @acct3.generate_otp
    
    # Don't throw errors from the SMS client
    FakeSMS.throw_error = nil
  end


  test "Fetch products" do 
    get "/api/products"
    assert_response :success
    
    products = JSON.parse(response.body)
    assert_equal Product.count, products.size
    products.each{|p|
      assert p.key? "id"
      assert p.key? "name"
      assert p.key? "max_price_cents"
      assert p.key? "icon"
      assert p.key? "icon_url"
      assert p.key? "type"
    }
  end

  # test "the truth" do
  #   assert true
  # end
  test "Request OTP succeeds" do

    MessageSender.client.messages.clear
    
    assert_difference 'MessageSender.client.messages.size', 1 do
      post "/api/requestOneTimePasscode", params: {phone_number: number_to_phone(@acct1.phone_number.to_s), device_id: @devId}, as: :json
      assert_response :success
    end
    
  end
  
  test "request OTP with unknown number creates a new account" do
    number = "(555) 555-5555"
    assert_nil Account.search_by_phone_number(number)
    
    post "/api/requestOneTimePasscode", params: {phone_number: number, device_id: @devId}, as: :json
    assert_response :success
        
    acct = Account.search_by_phone_number(number)
    assert_not_nil acct
    assert_equal @devId, acct.device_id
  end
  
  test "request OTP without device id creates an account without" do
    number = "(555) 555-5556"
    assert_nil Account.search_by_phone_number(number)
    
    post "/api/requestOneTimePasscode", params: {phone_number: number}, as: :json
    assert_response :success
    
    acct = Account.search_by_phone_number(number)
    assert_not_nil acct
    assert_nil acct.device_id
  end
  
  test "request OTP creates an account with an empty device id" do
    number = "(555) 555-5556"
    assert_nil Account.search_by_phone_number(number)
    
    post "/api/requestOneTimePasscode", params: {phone_number: number, device_id: ""}, as: :json
    assert_response :success
    
    acct = Account.search_by_phone_number(number)
    assert_not_nil acct
    assert_nil acct.device_id
  end
  
  test "request OTP returns 500 if SMS fails" do
    FakeSMS.throw_error = "Testing Error"
    
    number = "(555) 555-5557"
    assert_nil Account.search_by_phone_number(number)
    
    post "/api/requestOneTimePasscode", params: {phone_number: number, device_id: ""}, as: :json
    assert_response :internal_server_error
    
    log_entry = Log.last
    assert log_entry.message.index(FakeSMS.throw_error)
    
  end
  
  test "Authentication Succeeds" do
    post "/api/authenticate", params: {phone_number: @acct1.phone_number.to_s, pass_code: @acct1_passcode, device_id: @devId}, as: :json  
    
    assert_response :success
    json = JSON.parse(@response.body) 
    assert_not_nil json["auth_token"]
  end
  
  test "Authenticate without deviceid succeeds" do
    post "/api/authenticate", params: {phone_number: @acct1.phone_number.to_s, pass_code: @acct1_passcode, device_id: ""}, as: :json  
    
    assert_response :success
    json = JSON.parse(@response.body) 
    assert_not_nil json["auth_token"]
  end
  
  test "Authentication with invalid OTP fails" do
    bad_otp = "not a passcode"
    post "/api/authenticate", params: {phone_number: @acct1.phone_number.to_s, pass_code: bad_otp, device_id: @devId}, as: :json  
    
    assert_response :unauthorized
  end
  
  test "Fetch Passes succeeds" do
    
    post "/api/authenticate", params: {phone_number: @acct1.phone_number.to_s, pass_code: @acct1_passcode, device_id: @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
    
    # Posting with no parameters will return all passes
    post "/api/passes", params: {authorization: token}
    assert_response :ok
    passes = JSON.parse(@response.body)
    
    assert_equal @acct1.passes.count, passes.size
    # Verify json structure
    assert_equal ["name", "phone_number", "email"], passes.first["purchaser"].keys
    
  
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/passes", params: {authorization: token, serialNumbers: ["abc123", "abc124"]}
    passes = JSON.parse(@response.body)
    
    assert_equal 2, passes.size
    assert_equal "EXPIRED", passes.find{|p| p["serialNumber"] == "abc123"}["status"]
    assert_equal "VALID", passes.find{|p| p["serialNumber"] == "abc124"}["status"]
    
  end
  
  test "Fetch a pass with an emoji" do
    post "/api/authenticate", params: {phone_number: @acct3.phone_number.to_s, pass_code: @acct3_passcode, device_id: @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
    
    # Posting with no parameters will return valid passes
    post "/api/passes", params: {authorization: token}
    passes = JSON.parse(@response.body)
    assert_equal 1, passes.size
    assert_equal "This pass has an emoji \u{1F44D}", passes.first["message"]
  
  end
  
  test "Fetch Invalid Pass" do
  
    post "/api/authenticate", params: {phone_number: @acct1.phone_number.to_s, pass_code: @acct1_passcode, device_id: @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/passes", params: {authorization: token, serialNumbers: ["12345abc"]}
    passes = JSON.parse(@response.body)
    
    # Verify that invalid serial returns invalid pass
    assert_equal @acct1.passes.count+1, passes.size
    assert_equal "INVALID", passes.find{|p| p["serialNumber"] == "12345abc"}["status"]
    
  end
  
  
  test "Fetch Passes unauthorized" do
    
    token = "ThisIs.NotA.Token"
    
    post "/api/passes", params: {authorization: token, serialNumbers: ["abc123", "abc124"]}
    body = JSON.parse(@response.body)
    assert_response :unauthorized
    assert_not_nil(body["error"])
    
  end
  
  test "Place Order Succeeds" do
    
    post "/api/authenticate", params: {phone_number: @acct1.phone_number.to_s, pass_code: @acct1_passcode, device_id: @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/place_order",  
      params: {authorization: token,
               recipients: [@acct1.phone_number.to_s],
               message: "So Long and Thanks for all the Fish",
               payment_source: "mock_payment_source_token",
               product: {id: products(:beer).id, type: "Product"}}
    
    assert_response :success
    order = JSON.parse(@response.body)
    o = Order.find(order["order_id"].to_i)
    assert_not_nil o.charge_stripe_id
    assert_equal products(:beer).max_price_cents, o.commitment_amount_cents
    assert products(:beer).max_price_cents < o.charge_amount_cents
  end
  
  test "Place order without authorization fails" do 
     
    assert_no_difference "Order.count" do
      post "/api/place_order", 
        params: {authorization: "Not.a.token",
                 recipients: ["310-909-7243","5043834228"],
                 message: "So Long and Thanks for all the Fish", 
                 product: {id: promotions(:generic).id, type: "Promotion"}}
      assert_response :unauthorized
    end
  end
  
  test "Account History Succeeds" do
    post "/api/authenticate", params: {phone_number: @acct2.phone_number.to_s, pass_code: @acct2_passcode, device_id: @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    
    # Posting with an array of serial numbers will return those serial numbers
    post "/api/history", params: {authorization: token}
    assert_response :success
    history = JSON.parse(@response.body)
    assert history.size == 3
    
    assert_equal ["id", "date", "activity_type", "message"], history.first.keys
  end
  
  test "Account History Unauthorized" do
    
    post "/api/history", params: {authorization: "Not.A.Token"}
    assert_response :unauthorized
    
  end
  
  test "Fetch pass data - Authorized" do
    
    post "/api/authenticate", params: {phone_number: @acct1.phone_number.to_s, pass_code: @acct1_passcode, device_id: @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    pass = passes(:distant_future)
  
    post "/api/pass/#{pass.serial_number}", params: {authorization: token}
    assert_response :ok
  end
  
  
  test "Fetch another users pass data returns 404" do
    
    post "/api/authenticate", params: {phone_number: @acct2.phone_number.to_s, pass_code: @acct2_passcode, device_id: @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
  
    pass = passes(:distant_future)
  
    post "/api/pass/#{pass.serial_number}", params: {authorization: token}
    assert_response :not_found
  end
  
  test "Fetch pass data when Unuthorized" do
    pass = passes(:distant_future)
    post "/api/pass/#{pass.serial_number}"
    assert_response :unauthorized
  end


  
  test "Unknown user places an order succeeds" do
    purchaser = {name: "New User", phone: "000-000-1000", email: "test@toou.gifts"}
    product = {type: "Product", id: products(:beer).id}
    recipients = [accounts(:josh).phone_number]
    payment_source = "visa_tok"
    message = "Test"
    
    assert_nil Account.search_by_phone_number(purchaser[:phone])
    
    assert_difference "Order.count", 1 do
      post "/api/order", params: {purchaser: purchaser, product: product, recipients: recipients, payment_source: payment_source, message: message}
      assert_response :ok
      o = Order.last
      assert_not_nil o.charge_stripe_id
      assert_equal products(:beer).max_price_cents, o.commitment_amount_cents
      assert o.commitment_amount_cents < o.charge_amount_cents
    end
    
  end
  
  test "Fetch merchants" do
    post "/api/merchants", params: {query: {}}
    
    validMerchants = Merchant.joins(:merchant_products).distinct.select{|m| m.stripe_id != nil}
    assert_equal  validMerchants.count, JSON.parse(response.body).count
    
    post "/api/merchants", params: {query: {name: merchants(:quantum).name[0..3]}}
    assert_equal 1, JSON.parse(response.body).count
  end
  
  test "Fetch merchants by product" do
    post "/api/merchants", params: {query: {product_id: products(:beer).id}}
    assert_response :ok
    assert_equal 1, JSON.parse(response.body).count
  end
end
