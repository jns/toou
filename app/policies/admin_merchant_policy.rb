class AdminMerchantPolicy < AdminPolicy 
    
   def update?
      return user.admin? 
   end
end