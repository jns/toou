require 'test_helper'

class MerchantApiControllerTest < ActionDispatch::IntegrationTest

	def auth_merchant(merchant, password)
	    
	    user = merchant.user
	    otp = user.generate_otp_for_device("test_device")
	    
	    post "/api/authenticate_merchant_device", params: {data: {device: "test_device", password: otp}}, as: :json  
	    assert_response :ok
	    json = JSON.parse(@response.body) 
	    token = json["auth_token"]
	    assert_not_nil token
	    token
	end
	
	test "request passcode" do
		user = users(:quantum_user)
		post "/api/merchant/request_passcode", params: {data: {email: user.email, device: "test_device2"}}
	    assert_response :ok

	end
	
	test "Update merchant" do
		token = auth_merchant(merchants(:quantum), "beer")
		
		put "/api/merchant", params: {authorization: token, data: {name: "name", website: "website", phone_number:"phone_number"}}
		assert_response :ok
		assert_equal "name", response.body["name"]
		assert_equal "website", response.body["website"]
		assert_equal "phone_number", response.body["phone_number"]
	end
	
	test "products" do
		merchant = merchants(:quantum)
		token = auth_merchant(merchant, "beer")
		post "/api/merchant/products", params: {authorization: token}
		assert_response :ok
		JSON.parse(response.body).each do |p|
			product = Product.find(p["id"])
			assert_equal product.can_redeem?(merchant), p["can_redeem"]	== "true" ? true : false
		end
	end
	
	test "update merchant product price" do
		merchant = merchants(:quantum)
		token = auth_merchant(merchant, "beer")
		beer = products(:beer)
		qbeer = merchant_products(:quantum_beer)
		cupcake = products(:cupcake)
		put "/api/merchant/products", params: {authorization: token, data: {product: {id: beer.id, price_cents: qbeer.price_cents+1, can_redeem: true}}}
		assert_response :ok
		
		JSON.parse(response.body).each do |p|
			if p["id"] == beer.id
				assert p["price_cents"] == qbeer.price_cents+1	
			end
		end
	end
	
		
	test "update merchant product can redeem" do
		merchant = merchants(:quantum)
		token = auth_merchant(merchant, "beer")
		beer = products(:beer)
		cupcake = products(:cupcake)
		put "/api/merchant/products", params: {authorization: token, data: {product: {id: beer.id, can_redeem: false}}}
		assert_response :ok
		
		JSON.parse(response.body).each do |p|
			if p["id"] == beer.id
				assert_equal "false", p["can_redeem"] 	
			end
		end
	end
end