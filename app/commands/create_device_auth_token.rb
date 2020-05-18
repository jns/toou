# @DEPRECATED
class CreateDeviceAuthToken
  
  prepend SimpleCommand
  
  def initialize(device, password)
    @device = device
    @password = password
  end

  def call
    user = get_user
    JsonWebToken.encode(user_id: user.id, user_type: "User") if user
  end

  private

  attr_accessor :device, :password

  def get_user
    if device
      user = device.merchant.user
      return user if user && user.authenticate_device(device, password)
    end
    
    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end