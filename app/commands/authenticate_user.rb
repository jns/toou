class AuthenticateUser
  
  prepend SimpleCommand
  
  def initialize(phone, one_time_password)
    @phone = phone
    @otp = one_time_password
  end

  def call
    JsonWebToken.encode(user_id: user.id) if user
  end

  private

  attr_accessor :phone, :otp

  def user
    user = PhoneNumber.find_by_string(phone).account
    return user if user && user.authenticate(otp)

    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end