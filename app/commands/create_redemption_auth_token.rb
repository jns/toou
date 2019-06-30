class CreateRedemptionAuthToken
 
  prepend SimpleCommand
  
  def initialize(merchant, device_id)
    @merchant = merchant
    @device_id = device_id
    
  end

  def call
    begin
      device = @merchant.devices.find {|d| d.device_id === @device_id }
      unless device
        device = Device.create(merchant: @merchant, device_id: @device_id)
      end
      JsonWebToken.encode(user_id: device.id, user_type: "MerchantDevice", datetime: Time.new) 
    rescue
      errors.add(:creation_error, "Error creating device token")
    end
  end

end