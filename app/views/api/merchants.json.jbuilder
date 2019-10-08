json.array! @merchants do |merchant|
	json.id merchant.id
	json.name merchant.name
	json.website merchant.website
	json.logo url_for(merchant.logo.variant(resize: "75x75"))
	
	json.location do 
		json.address1 merchant.address1
		json.address2 merchant.address2
		json.city merchant.city
		json.state merchant.state
		json.zip merchant.zip
		json.latitude merchant.latitude
		json.longitude merchant.longitude
	end
end