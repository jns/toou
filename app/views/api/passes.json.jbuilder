json.array! @passes do |pass|
    json.serialNumber pass.serialNumber
    json.expiration pass.expiration
    json.passTypeIdentifier pass.passTypeIdentifier
    json.message pass.message
    json.status pass.status
    json.purchaser do 
        json.name pass.purchaser.name
        json.mobile pass.purchaser.primary_phone_number
        json.email pass.purchaser.email
    end
end
