class User < ApplicationRecord
    
    has_and_belongs_to_many :roles
    has_many :accounts
    
    # Used to reset the password.  Stored as a digest in the database
    attr_accessor :reset_token
    
    TEST_USERNAME = "tester"
        
    validates :username,  presence: true, length: { maximum: 50 }

    def User.find_or_create_mobile_phone_account(phone_number, email, name)
        phone = PhoneNumber.new(phone_number).to_s
        begin
            a = Account.find(phone_number: phone)
            # Update name and email if they are nil
            a.update(email: email) unless a.email
            a.user.update(first_name: name) unless a.user.first_name
            return a
        rescue ActiveRecord::RecordNotFound
            u = User.create(username: phone, first_name: name)
            a = MobilePhoneAccount.create(phone_number: phone, email: email, user: u)
            return a
        end
    end

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
