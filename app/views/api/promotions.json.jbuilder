json.array! @promotions do |promotion|
    json.id promotion.id
    json.name promotion.name
    json.copy promotion.copy
    json.value_cents promotion.value_cents
    json.product promotion.product
    json.value_dollars number_to_currency(promotion.value_dollars)
    json.end_date promotion.end_date.to_date.to_formatted_s(:short)
    json.qty_remaining promotion.remaining_quantity
end