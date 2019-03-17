class User < ApplicationRecord
    has_secure_password
    has_and_belongs_to_many :roles
    
    def admin?
       roles.member?(Role.admin) 
    end
    
    def merchant?
       roles.member?(Role.merchant) 
    end
    
    def merchant
       if merchant?
           Merchant.find_by(user: self)
       else
           nil
       end
    end
end
