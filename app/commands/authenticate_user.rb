class AuthenticateUser
  
  prepend SimpleCommand
  
  
  def initialize(identity, password, auth_method=Account::AUTHX_OTP)
    @identity = identity
    @password = password
    @method = auth_method
  end

  def call
    u = case @method 
    when Account::AUTHX_OTP
      phone = PhoneNumber.new(@identity).to_s
      Account.where(authentication_method: Account::AUTHX_OTP, phone_number: phone).first
    when Account::AUTHX_PASSWORD
      Account.where(authentication_method: Account::AUTHX_PASSWORD, email: @identity).first
    end
    
    if u and u.authenticate(@password)
      u.token = JsonWebToken.encode({user_id: u.id, user_type: "Customer"}) 
      return u
    else
      errors.add :unauthorized, 'invalid credentials'
    end

  end

end