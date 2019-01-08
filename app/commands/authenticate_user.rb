class AuthenticateUser
  
  prepend SimpleCommand
  
  def initialize(phone, one_time_password)
    @phone = PhoneNumber.new(phone).to_s
    @otp = one_time_password
  end

  def call
    JsonWebToken.encode(user_id: user.id) if user
  end

  private

  attr_accessor :phone, :otp

  def user
    user = Account.find_by_phone_number(@phone)
    return user if user && user.authenticate(otp)

    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end