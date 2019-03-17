require 'test_helper'

class MerchantApiControllerTest < ActionDispatch::IntegrationTest

	def auth_merchant(merchant, password)
	    
	    user = merchant.user
	    user.update(password: password)
	    
	    post "/api/authenticate_merchant", params: {data: {username: user.username, password: password}}, as: :json  
	    assert_response :ok
	    json = JSON.parse(@response.body) 
	    token = json["auth_token"]
	    assert_not_nil token
	    token
	end
	
  
	test "Update merchant" do
		token = auth_merchant(merchants(:quantum), "beer")
		
		put "/api/merchant", params: {authorization: token, data: {name: "name", website: "website", phone_number:"phone_number"}}
		assert_response :ok
		assert_equal "name", response.body["name"]
		assert_equal "website", response.body["website"]
		assert_equal "phone_number", response.body["phone_number"]
	end
end