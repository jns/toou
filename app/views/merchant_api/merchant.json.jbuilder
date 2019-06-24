json.name @merchant.name
json.email @current_user.username
json.website @merchant.website
json.phone_number @merchant.phone_number
json.enrolled @merchant.enrolled

json.location do
	json.address1 @merchant.address1
	json.address2 @merchant.address2
	json.city @merchant.city
	json.state @merchant.state
	json.zip @merchant.zip
end
