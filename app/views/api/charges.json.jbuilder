json.array! @charges do |charge|
    json.date charge.created_at
    json.amount_cents charge.destination_amount_cents                                                                             
end