class User < ApplicationRecord
    
    has_and_belongs_to_many :roles
    has_many :accounts

    
    TEST_USERNAME = "tester"
        
    validates :username,  presence: true, length: { maximum: 50 }

    def User.find_or_create_mobile_phone_account(phone_number, email, name)
        phone = PhoneNumber.new(phone_number).to_s
        a = Account.find_by(phone_number: phone)
        if a
            # Update name and email if they are nil
            if email and a.email == nil
                a.update(email: email) 
            end
            if name and a.user.first_name == nil
                a.user.update(first_name: name)
            end
            return a
        else
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
    
    # Convenience method created when emails where moved into EmailAccounts
    # This takes the first found email, and is not guaranteed to be the same from 
    # one call to the next.
    def first_email
      accounts.where("email is not null").first.email 
    end
    
end
