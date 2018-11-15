class Account < ActiveRecord::Base
    has_many :passes
    has_many :orders
    
    before_save do 
        self.mobile = Account.sanitize_phone_number(mobile) if attribute_present?("mobile") 
    end
    
    def Account.sanitize_phone_number(number)
        number.gsub(/[^0-9]/, "")
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
