class User < ApplicationRecord
    
    has_and_belongs_to_many :roles
    has_many :accounts
    has_many :passes, as: :recipient
    has_many :orders
    has_many :memberships
    has_many :groups, through: :memberships

    after_create :generate_stripe_customer

    # Cache the id of the account used to authenticate this user
    @authenticated_with_id 

    
    TEST_USERNAME = "tester"
        
    validates :username,  presence: true, length: { maximum: 50 }

    def name
       return "#{first_name} #{last_name}" 
    end
    
    def name=(first, last=nil)
        update(first_name: first, last_name: last)
    end

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
    alias :email :first_email

    # Convenience method to extract first phone number
    def phone_number
        accounts.where("phone_number is not null").first.phone_number    
    end

    # Cache the id of the account used to authenticate this user
    # Do not cache actual account so that rails re-polls database 
    # when user accesses authenticated_with 
    def authenticated_with=(account)
        if (accounts.member?(account))
           @authenticated_with_id = account.id
       else
           @authenticated_with_id = nil
       end
       
    end
    
    # Returns the account used to authenticate this user
    def authenticated_with
        accounts.find(@authenticated_with_id)
    end
    
    # Creates a stripe customer account for this user
    def generate_stripe_customer
        CreateStripeCustomerJob.perform_now(self.id)
        reload
    end
end
