json.array! @devices do |device|
    json.id device.id
    json.device_id device.device_id
    json.merchant_id device.merchant_id
end