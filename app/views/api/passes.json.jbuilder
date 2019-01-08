json.array! @passes do |pass|
    json.serialNumber pass.serialNumber
    json.expiration pass.expiration
    json.passTypeIdentifier pass.passTypeIdentifier
    json.message pass.message
    json.status pass.status
    json.purchaser do 
        json.phone_number pass.purchaser.phone_number
        json.email pass.purchaser.email
    end
end
