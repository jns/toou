module MerchantsHelper

	def stripe_connect_url
		url = "https://connect.stripe.com/express/oauth/authorize"
		url +="?redirect_uri=#{merchants_enroll_url}"
		url += "&client_id=#{ENV["STRIPE_CLIENT_ID"]}"
		url += "&state=#{@merchant.id}"
		url += "&stripe_user[email]=#{@merchant.user.username}"
		url += "&stripe_user[business_name]=#{@merchant.name}"
		url += "&stripe_user[business_type]=company"
		url += "&stripe_user[phone_number]=#{@merchant.phone_number}"
		return URI.encode(url)
	end
	
	def stripe_dashboard_url(stripe_id)
		account = Stripe::Account.retrieve(stripe_id)
		links = account.login_links.create()
		links.url
	end
	
end