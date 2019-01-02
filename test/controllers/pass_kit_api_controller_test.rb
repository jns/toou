require 'test_helper'

class PassKitApiControllerTest < ActionDispatch::IntegrationTest

  def setup()
    # Seed test database with countries
    load "#{Rails.root}/db/seeds.rb"
  end

  # This test asserts that a JWT generated for accessing the TooU client api 
  # cannot be reused for accessing the pkpass api
  # !!!CAVEAT!!!  This assertion exists to prevent anyone that can get the pass 
  # cannot access a user information from the client API.
  test "Unauthorized if Auth headers are not compatible" do
    
    # Generate a token 
    acct = accounts(:josh)
    otp = acct.generate_otp
    @devId = "12345"
    
    post "/api/authenticate", params: {"phoneNumber": acct.primary_phone_number.to_s, "passCode": otp, "deviceId": @devId}, as: :json  
    json = JSON.parse(@response.body) 
    token = json["auth_token"]
    
    pass = passes(:abc123)
    get "/v1/passes/#{pass.passTypeIdentifier}/#{pass.serialNumber}", headers: {"Authorization": "ApplePass #{token}"}
    assert_response :unauthorized
    
  end
  
  
  # This test verifies that the endpoint parameters and the auth token are compatible
  test "Fetch a pass - Auth headers match endpoint parameters" do
    pass = passes(:abc123)
    token = JsonWebToken.encode(pass_id: pass.id)
    get "/v1/passes/#{pass.passTypeIdentifier}/#{pass.serialNumber}", headers: {"Authorization": "ApplePass #{token}"}
    assert_response :ok
  end
  
  # This test verifies that the server returns Unauthorized if the parameters do not
  # match the auth token
  test "Fetch a pass - UNAUTHORIZED if auth headers do not match endpoint params" do
    passABC123 = passes(:abc123)
    passABC126 = passes(:abc126)
    token = JsonWebToken.encode(pass_id: passABC123.id)
    get "/v1/passes/#{passABC126.passTypeIdentifier}/#{passABC126.serialNumber}", headers: {"Authorization": "ApplePass #{token}"}
    assert_response :unauthorized
  end
  
  
  # This test verifies that the server returns Unauthorized if the parameters do not
  # match the auth token
  test "Fetch a pass - UNAUTHORIZED if token is bad" do
    passABC126 = passes(:abc126)
    token = "Not.a.Token"
    get "/v1/passes/#{passABC126.passTypeIdentifier}/#{passABC126.serialNumber}", headers: {"Authorization": "ApplePass #{token}"}
    assert_response :unauthorized
  end
end
