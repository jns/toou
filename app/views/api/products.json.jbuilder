json.array! @products do |product|
    json.id product.id
    json.name product.name
    json.max_price_cents product.max_price_cents
    json.icon product.icon
    json.type product.class.name
end