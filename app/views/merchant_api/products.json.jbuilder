json.array! @products do |product|
    json.id product.id
    json.name product.name
    json.max_price_cents product.max_price_cents
    json.max_price_dollars product.price(:dollars)
    json.icon product.icon
    json.type product.class.name
    json.can_redeem (product.can_redeem?(@merchant) ? true : false)
    json.price_cents product.merchant_price_cents(@merchant)
end