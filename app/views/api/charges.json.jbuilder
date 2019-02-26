json.array! @charges do |charge|
    json.id charge.id
    json.date charge.created_at
    json.amount_cents charge.destination_amount_cents                                                                             
end