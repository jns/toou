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
      if user_type === "Customer"
        return Account.find(user_id)
      elsif user_type === "User"
        return User.find(user_id)
      elsif user_type === "Merchant"
        return Merchant.find(user_id)
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