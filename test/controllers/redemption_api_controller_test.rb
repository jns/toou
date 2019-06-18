require 'test_helper'

class RedemptionApiControllerTest < ActionDispatch::IntegrationTest

    
    def authenticate_merchant(merchant)
	    post "/api/redemption/authorize_device", params: {data: {merchant_id: merchant.id}}, as: :json  
	    assert_response :ok
	    json = JSON.parse(@response.body) 
	    token = json["auth_token"]
	    assert_not_nil token
	    token
    end
    
    def perform_valid_redemption
        merchant = merchants(:quantum)
        pass = passes(:redeemable_pass)
        code = get_code(merchant, pass)
        perform_redemption(merchant, code)        
    end 
    
    def get_code(merchant, pass)
        customer = pass.account
        customer_token = forceAuthenticate(customer)
        # Get a valid code
        post "/api/redemption/get_code", params: {authorization: customer_token, data: {merchant_id: merchant.id, pass_sn: pass.serial_number}}, as: :json
	    json = JSON.parse(@response.body)
	    code = json["code"]
        return code        
    end
    
    def perform_redemption(merchant, code)
        merchant_token = authenticate_merchant(merchant)
	    # Redeem it
	    post "/api/redemption/redeem", params: {authorization: merchant_token, data: {code: code}}, as: :json
    end
	
    test "User can get a code for own pass" do
        merchant = merchants(:quantum)
        pass = passes(:redeemable_pass)
        customer = pass.account
        token = forceAuthenticate(customer)
        
        post "/api/redemption/get_code", params: {authorization: token, data: {merchant_id: merchant.id, pass_sn: pass.serial_number}}, as: :json
	    assert_response :ok
	    json = JSON.parse(@response.body)
	    assert json["code"]
	    assert json["code"] =~ /\d{4}/
	    
    end
    
    test "Return 404 when customer requests code for another customer's pass" do
        merchant = merchants(:quantum)
        pass = passes(:redeemable_pass)
        customer = accounts(:pete)
        assert_not_equal customer, pass.account
        
        token = forceAuthenticate(customer)
        
        post "/api/redemption/get_code", params: {authorization: token, data: {merchant_id: merchant.id, pass_sn: pass.serial_number}}, as: :json
	    assert_response :not_found
    end 
    
    test "Merchant can redeem a valid code" do
	    perform_valid_redemption
	    assert_response :ok
    end 
    
    test "Test successful redemption includes amount" do
        perform_valid_redemption
        json = JSON.parse(@response.body)
	    assert_not_nil json["amount"]
	end 
	
	test "Test pass is used after redemption" do
	    merchant = merchants(:quantum)
	    pass = passes(:redeemable_pass)
	    code = get_code(merchant, pass)
	    perform_redemption(merchant, code)
	    pass.reload
	    assert pass.used?
	end
 
    test "Test that merchant cannot redeem same code twice" do
        merchant = merchants(:quantum)
	    pass = passes(:redeemable_pass)
	    code = get_code(merchant, pass)
	    perform_redemption(merchant, code)
	    assert_response :ok
        
        perform_redemption(merchant, code)
	    assert_response :bad_request
    end
    
    test "Test that failed redemption does not create a transfer" do
       # Force insert a code for an invalid pass (This will normall get stopped by other checks)
       code = "9999"
       merchant = merchants(:quantum)
       pass = passes(:expired)
       MerchantPassQueue.create(merchant: merchant, pass: pass, code: code)
    
        assert_no_difference 'MockStripeTransfer.transfers.count' do
           perform_redemption(merchant, code)
           assert_response :bad_request
           pass.reload
           assert_nil pass.transfer_stripe_id
           assert_nil pass.transfer_amount_cents
           assert_nil pass.transfer_created_at
        end
    end
    
    test "Redemption creates a charge" do
        
        merchant = merchants(:quantum)
        pass = passes(:redeemable_pass)
        code = get_code(merchant, pass)
    
        assert_difference ->{merchant.charges.count} do
            perform_redemption(merchant, code)
        end
    end
end
