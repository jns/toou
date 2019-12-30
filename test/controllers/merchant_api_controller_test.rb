require 'test_helper'

class MerchantApiControllerTest < ActionDispatch::IntegrationTest

	def auth_merchant(merchant, password = "password")
	    user = merchant.user
	    user.update(password: password)
	    
	    post "/api/user/authenticate", params: {data: {username: user.username, password: password}}, as: :json  
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
		
		put "/api/merchant", params: {authorization: token, data: {merchant_id: merchants(:quantum).id, name: "name", website: "website", phone_number:"(555) 555-5555"}}
		assert_response :ok
		body = JSON.parse(response.body)
		assert_equal "name", body["name"]
		assert_equal "website", body["website"]
		assert_equal "+15555555555", body["phone_number"]
	end
	
	test "products" do
		merchant = merchants(:quantum)
		token = auth_merchant(merchant)
		post "/api/merchant/products", params: {authorization: token, data: {merchant_id: merchant.id}}
		assert_response :ok
		JSON.parse(response.body).each do |p|
			product = Product.find(p["id"])
			assert_equal product.can_redeem?(merchant), p["can_redeem"]
		end
	end
	
	test "update merchant product price" do
		merchant = merchants(:quantum)
		token = auth_merchant(merchant)
		beer = products(:beer)
		qbeer = merchant_products(:quantum_beer)
		cupcake = products(:cupcake)
		put "/api/merchant/products", params: {authorization: token, data: {merchant_id: merchant.id, products: [{id: beer.id, price_cents: qbeer.price_cents+1, can_redeem: true}]}}
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
		put "/api/merchant/products", params: {authorization: token, data: {merchant_id: merchant.id, products: [{id: beer.id, can_redeem: false}, {id: cupcake.id, can_redeem: true}]}}
		assert_response :ok

		JSON.parse(response.body).each do |p|
			if p["id"] == beer.id
				refute p["can_redeem"]
				assert_equal beer.max_price_cents, p["price_cents"]
			end
			if p["id"] == cupcake.id
				assert  p["can_redeem"]
				assert_equal cupcake.max_price_cents, p["price_cents"]
			end
		end
	end
	
	test "authorize a device with email and password" do
		merchant = merchants(:quantum)
		user = merchant.user
		user.password = "a password"
		user.save
		device = "Device555"
		
		assert_difference "merchant.devices.count", 1 do
			post "/api/merchant/authorize_device", params: {authorization: {email: user.email, password: "a password"}, data: {device_id: device}}, as: :json
			assert_response :ok
		    json = JSON.parse(@response.body) 
			secret = json["secret"]
	
			post "/api/merchant/authorize_device", params: {authorization: {secret: secret}, data: {device_id: device, merchant_id: merchant.id}}, as: :json
			assert_response :ok
			json = JSON.parse(@response.body)
		    token = json["auth_token"]
		    assert_not_nil token
		end
	end
	
	test "authorize a device with email and password for a user with multiple merchants" do
		merchant = merchants(:cupcake_store2)
		user = merchant.user
		user.password = "a password"
		user.save
		device = "CupcakeTooDevice"
		
		assert_difference "merchant.devices.count", 1 do
			post "/api/merchant/authorize_device", params: {authorization: {email: user.email, password: "a password"}, data: {device_id: device}}, as: :json
			assert_response :ok
		    json = JSON.parse(@response.body) 
		    secret = json["secret"]
		    assert_not_nil secret
		    
		    post "/api/merchant/authorize_device", params: {authorization: {secret: secret}, data: {merchant_id: merchant.id, device_id: device}}, as: :json
			assert_response :ok
		    json = JSON.parse(@response.body)
		    token = json["auth_token"]
		    assert_not_nil token
		    
		end
		
	end
	
	test "authorize without authorization fails" do
		merchant = merchants(:quantum)
		device = "A Device"
		assert_no_difference "merchant.devices.count" do
			post "/api/merchant/authorize_device", params: {data: {merchant_id: merchant.id, device_id: device}}, as: :json
			assert_response :unauthorized
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
	    assert_equal 4, credits.size
	end 
	
	test "stripe link returns enrollment link for unenrolled merchant" do
		merchant = merchants(:unenrolled_store)
	    token = auth_merchant(merchant)
	    
	    post "/api/merchant/stripe_link", params: {authorization: token, data: {merchant_id: merchant.id}}
	    assert_response :ok
	    body = JSON.parse(response.body)
	    url = URI.decode(body["url"])
	    assert_not_nil url
	    assert Regexp.new(merchant.user.email).match(url)
	    assert Regexp.new(merchant.name).match(url)
	    assert Regexp.new(merchant.phone_number).match(url)
	end
end