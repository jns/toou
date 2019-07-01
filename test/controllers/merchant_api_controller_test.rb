require 'test_helper'

class MerchantApiControllerTest < ActionDispatch::IntegrationTest

	def auth_merchant(merchant, password = "password")
	    user = merchant.user
	    user.update(password: password)
	    
	    post "/api/merchant/authenticate", params: {data: {username: user.username, password: password}}, as: :json  
	    assert_response :ok
	    json = JSON.parse(@response.body) 
	    token = json["auth_token"]
	    assert_not_nil token
	    token
	end
	
	def auth_device(token, merchant, device)
		post "/api/merchant/authorize_device", params: {authorization: token, data: {merchant_id: merchant.id, device_id: device}}, as: :json
		assert_response :ok
		json = JSON.parse(@response.body)
		token = json["auth_token"]
		assert_not_nil token
		assert_not_nil merchant.reload.devices.find{|d| d.device_id === device}
		token
	end

	test "Deauthorize a device" do
		m = merchants(:quantum)
		token = auth_merchant(m, "beer")
		auth_device(token, m, "test_device")
		device = Device.find_by(merchant: m, device_id: "test_device")
		assert_difference "m.devices.count", -1 do 
			post "/api/merchant/deauthorize", params: {authorization: token, data: {merchant_id: m.id, device_id: device.id}}
			assert_response :ok
		end
	end
	
	test "Deauthorize a non-existent device" do 
		token = auth_merchant(merchants(:quantum))
		post "/api/merchant/deauthorize", params: {authorization: token, data: {merchant_id: merchants(:quantum).id, device_id: "nonexistent_device"}}
		assert_response :ok
	end
	
	test "Update merchant" do
		token = auth_merchant(merchants(:quantum))
		
		put "/api/merchant", params: {authorization: token, data: {merchant_id: merchants(:quantum).id, name: "name", website: "website", phone_number:"phone_number"}}
		assert_response :ok
		assert_equal "name", response.body["name"]
		assert_equal "website", response.body["website"]
		assert_equal "phone_number", response.body["phone_number"]
	end
	
	test "products" do
		merchant = merchants(:quantum)
		token = auth_merchant(merchant)
		post "/api/merchant/products", params: {authorization: token, data: {merchant_id: merchant.id}}
		assert_response :ok
		JSON.parse(response.body).each do |p|
			product = Product.find(p["id"])
			assert_equal product.can_redeem?(merchant), p["can_redeem"]	== "true" ? true : false
		end
	end
	
	test "update merchant product price" do
		merchant = merchants(:quantum)
		token = auth_merchant(merchant)
		beer = products(:beer)
		qbeer = merchant_products(:quantum_beer)
		cupcake = products(:cupcake)
		put "/api/merchant/products", params: {authorization: token, data: {merchant_id: merchant.id, product: {id: beer.id, price_cents: qbeer.price_cents+1, can_redeem: true}}}
		assert_response :ok
		
		JSON.parse(response.body).each do |p|
			if p["id"] == beer.id
				assert p["price_cents"] == qbeer.price_cents+1	
			end
		end
	end
	
		
	test "update merchant product can redeem" do
		merchant = merchants(:quantum)
		token = auth_merchant(merchant)
		beer = products(:beer)
		cupcake = products(:cupcake)
		put "/api/merchant/products", params: {authorization: token, data: {merchant_id: merchant.id, product: {id: beer.id, can_redeem: false}}}
		assert_response :ok
		
		JSON.parse(response.body).each do |p|
			if p["id"] == beer.id
				assert_equal "false", p["can_redeem"] 	
			end
		end
	end
	
	test "authorize multiple devices simultaneously" do
		
		merchant = merchants(:quantum)
		token = auth_merchant(merchant)
		
		assert_difference "merchant.devices.count", 2 do
			dev_token1 = auth_device(token ,merchant, "device1")
			dev_token2 = auth_device(token, merchant, "device2")
			merchant.reload
		end
	end
	
	test "Merchant credits endpoint returns charges credited to merchant" do
	    merchant = merchants(:quantum)
	    token = auth_merchant(merchant)
	    
	    post "/api/merchant/credits", params: {authorization: token, data: {merchant_id: merchant.id}}
	    assert_response :ok
	    credits = JSON.parse(response.body)
	    assert_equal 1, credits.size
	end
end