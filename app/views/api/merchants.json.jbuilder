json.array! @merchants do |merchant|
	json.id merchant.id
	json.name merchant.name
	json.website merchant.website
	
	json.locations merchant.locations do |loc|
		json.address1 loc.address1
		json.address2 loc.address2
		json.city loc.city
		json.state loc.state
		json.zip loc.zip
		json.latitude loc.latitude
		json.longitude loc.longitude
	end
end