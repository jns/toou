class AuthenticateUser
  
  prepend SimpleCommand
  
  def initialize(phone, one_time_password)
    @phone = PhoneNumber.new(phone).to_s
    @otp = one_time_password
  end

  def call
    JsonWebToken.encode(user_id: user.id, user_type: "Customer") if user
  end

  private


  def user
    user = Account.find_by_phone_number(@phone)
    return user if user && user.authenticate(@otp)

    errors.add :unauthorized, 'invalid credentials'
    nil
  end
end