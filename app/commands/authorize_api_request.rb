class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(parameters)
    @parameters = parameters
  end

  def call
    token = @parameters[:authorization]
    if token === nil
      errors.add(:authentication, "Missing auth token")
      return
    end  
    
    decoded_token = JsonWebToken.decode(token)
    if decoded_token === nil
      errors.add(:authentication, "Error decoding token")
      return
    end
    
    user_type = decoded_token[:user_type]
    if user_type === nil
      errors.add(:authenitcation, "Missing user type")
      return
    end
    
    user_id = decoded_token[:user_id]
    if user_id === nil
      errors.add(:authentication, "Missing user id")
      return
    end
    
    begin
      if user_type === "User"
        u = User.find(user_id)
        if decoded_token[:auth_acct_id]
          u.authenticated_with = Account.find(decoded_token[:auth_acct_id])
        end
        return u
      elsif user_type === "MerchantDevice"
        return Device.find(user_id)
      else
        errors.add(:authentication, "Unknown User Type")
        return nil
      end
    rescue ActiveRecord::RecordNotFound
      errors.add(:authentication, "User not found") 
      return nil
    end

  end

end