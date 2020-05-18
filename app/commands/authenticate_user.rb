class AuthenticateUser
  
  prepend SimpleCommand
  
  
  def initialize(identity, password, auth_method=Account::AUTHX_OTP)
    @identity = identity
    @password = password
    @method = auth_method
  end

  def call
    acct = case @method 
    when Account::AUTHX_OTP
      phone = PhoneNumber.new(@identity).to_s
      Account.where(authentication_method: Account::AUTHX_OTP, phone_number: phone).first
    when Account::AUTHX_PASSWORD
      Account.where(authentication_method: Account::AUTHX_PASSWORD, email: @identity).first
    else
      nil
    end
    
    if acct and acct.authenticate(@password)
      user = acct.user 
      return JsonWebToken.encode({user_id: user.id, user_type: "User"}) 
    else
      errors.add :unauthorized, 'invalid credentials'
    end

  end

end