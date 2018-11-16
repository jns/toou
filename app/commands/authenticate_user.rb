class AuthenticateUser
  
  prepend SimpleCommand
  
  def initialize(phone, one_time_password)
    @phone = Account.sanitize_phone_number(phone)
    @otp = one_time_password
  end

  def call
    JsonWebToken.encode(user_id: user.id) if user
  end

  private

  attr_accessor :phone, :otp

  def user
    user = Account.find_by_mobile(phone)
    return user if user && user.authenticate(otp)

    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end