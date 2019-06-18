json.array! @charges do |charge|
    json.id charge[:id]
    json.created_at charge[:created_at]
    json.amount_cents charge[:amount_cents]                                                                             
end