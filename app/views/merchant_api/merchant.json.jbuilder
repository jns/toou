json.name @merchant.name
json.email @current_user.username
json.website @merchant.website
json.phone_number @merchant.phone_number
json.enrolled @merchant.enrolled

json.locations @merchant.locations do |loc|
	json.address1 loc.address1
	json.address2 loc.address2
	json.city loc.city
	json.state loc.state
	json.zip loc.zip
end
