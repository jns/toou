class Account < ActiveRecord::Base
    has_many :passes
    has_many :orders
    
    before_save do 
        self.mobile = Account.sanitize_phone_number(mobile) if attribute_present?("mobile") 
    end
    
    def Account.sanitize_phone_number(number)
        number.gsub(/U[0-9a-f]{4}/, "")
              .gsub(/[^0-9]/, "")
    end
    
    # Find an account using a predicate that can contain any of the following keys
    # phoneNumber, #email
    def Account.search_by(recipient)
        if recipient["phoneNumber"]
            a = Account.find_by(:mobile => Account.sanitize_phone_number(recipient["phoneNumber"]))
            return a if a != nil
        end
        
        if recipient["email"]
            a = Account.find_by(:email => recipient["email"])
            return a if a != nil
        end
        
        return nil
    end
    
    # Search for an account using the search_by function.  If the account isn't found, then create it
    def Account.search_or_create_by_recipient(recipient)
        a = Account.search_by(recipient)
        if a == nil then
            a = Account.create()
            a.name = recipient["name"]
            a.mobile = recipient["phoneNumber"]
            a.email = recipient["email"]
            a.save
        end
        
        return a
    end
    
    def authenticate(password)
        return self.one_time_password_hash == password
    end
    
    def generate_otp
        otp = rand(100000...999999).to_s
        self.one_time_password_hash = otp
        self.one_time_password_validity = Time.new
        if self.save
            otp
        else
            raise "Error generating password"
        end
    end
    
end
