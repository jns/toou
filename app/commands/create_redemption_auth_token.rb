class CreateRedemptionAuthToken
 
  prepend SimpleCommand
  
  def initialize(merchant, device_id)
    @merchant = merchant
    @device_id = device_id
    
  end

  def call
    device = @merchant.devices.select {|d| d.device_id === device_id }
    unless device
      device = Device.create(merchant: @merchant, device_id: device_id)
    end
    JsonWebToken.encode(user_id: device.id, user_type: "MerchantDevice", datetime: Time.new) 
  end

end