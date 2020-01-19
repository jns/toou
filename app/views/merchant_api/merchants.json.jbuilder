json.array! @merchants do |merchant|
    json.merchant_id @merchant.id
    json.name @merchant.name
    json.website @merchant.website
    json.phone_number @merchant.phone_number
    json.enrolled @merchant.enrolled
    json.address1 @merchant.address1
    json.address2 @merchant.address2
    json.city @merchant.city
    json.state @merchant.state
    json.zip @merchant.zip
    json.country (@merchant.country ? @merchant.country.abbreviation : nil)
    json.products @products, partial: 'merchant_api/product', as: :product
end