class AdminAccountPolicy < AdminPolicy 
    
   def update?
      return user.admin? 
   end
end