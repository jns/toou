class User < ApplicationRecord
    
    has_and_belongs_to_many :roles
    has_many :accounts
    
    # Used to reset the password.  Stored as a digest in the database
    attr_accessor :reset_token
    
    TEST_USERNAME = "tester"
        
    validates :username,  presence: true, length: { maximum: 50 }

    def admin?
       roles.member?(Role.admin) 
    end
    
    def merchant?
       roles.member?(Role.merchant) 
    end
    
    def tester?
        self.username == TEST_USERNAME and roles.member?(Role.tester)
    end
    
    def merchant
       if merchant?
           merchants.first
       else
           nil
       end
    end
    
    def merchants
       Merchant.where(user: self) 
    end
end
