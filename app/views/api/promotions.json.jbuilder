json.array! @promotions do |promotion|
    json.id promotion.id
    json.type promotion.class.name
    json.name promotion.name
    json.copy promotion.copy
    json.price_cents promotion.price_cents
    json.product promotion.product
    json.price_dollars number_to_currency(promotion.price(:dollars))
    json.end_date promotion.end_date.to_date.to_formatted_s(:short)
end