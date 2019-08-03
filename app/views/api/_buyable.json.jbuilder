
if buyable.is_a? Product
    product = buyable
    json.id product.id
    json.name product.name
    json.max_price_cents product.max_price_cents
    json.max_price_dollars product.price(:dollars)
    json.icon product.icon
    json.icon_url image_url("product_images/#{product.icon}-icon.png")
    json.type Product.name
elsif buyable.is_a? Promotion
    promotion = buyable
    json.id promotion.id
    json.name promotion.name
    json.type Promotion.name
end