json.array! @passes do |pass|
    json.serialNumber pass.serial_number
    json.expiration pass.expiration
    json.message pass.message
    json.status pass.status
    json.buyable do
        json.name pass.buyable.name
    end
    json.purchaser do 
        json.name pass.purchaser.name
        json.phone_number pass.purchaser.phone_number
        json.email pass.purchaser.email
    end
end
