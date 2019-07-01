class CreateRedemptionAuthToken
 
  prepend SimpleCommand
  
  def initialize(device)
    @device = device
  end

  def call
    begin
      JsonWebToken.encode(user_id: @device.id, user_type: "MerchantDevice", datetime: Time.new) 
    rescue
      errors.add(:creation_error, "Error creating device token")
    end
  end

end