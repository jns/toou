class AuthenticateUser
  
  prepend SimpleCommand
  
  def initialize(phone, one_time_password)
    @phone = PhoneNumber.new(phone).to_s
    @otp = one_time_password
  end

  def call
    u = Account.find_by_phone_number(@phone)
    if u and u.authenticate(@otp)
      JsonWebToken.encode({user_id: u.id, user_type: "Customer"}) 
    else
      errors.add :unauthorized, 'invalid credentials'
    end
  end

end