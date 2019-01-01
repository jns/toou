class Account < ActiveRecord::Base
    has_many :passes
    has_many :orders
    has_many :phone_numbers

    def primary_phone_number
       phone_numbers.first || ""
    end

    def Account.find_by_mobile(number)
        if p = PhoneNumber.find_by_string(number) 
           return p.account
        end
        return nil
    end

    # Find an account using a predicate that can contain any of the following keys
    # phoneNumber, email
    def Account.search_by(recipient)
        
        if recipient.is_a? Account
            return recipient
        end
        
        if recipient["phoneNumber"]
            phone = PhoneNumber.find_by_string(recipient["phoneNumber"])
            return phone.account if phone && phone.account
        end
        
        if recipient["email"]
            a = Account.find_by(email: recipient["email"])
            return a if a != nil
        end
        
        return nil
    end
    
    # Search for an account using the search_by function.  If the account isn't found, then create it
    def Account.search_or_create_by_recipient(recipient)
        a = Account.search_by(recipient)
        if a == nil then
            a = Account.create()
            phone = PhoneNumber.find_or_create_from_string(recipient["phoneNumber"]) 
            throw "Unable to create phone number: '#{recipient["phoneNumber"]}'" if phone == nil 
            throw "Phone Number is already affiliated with an account" unless phone.account == nil 
                
            a.name = recipient["name"]
            a.email = recipient["email"]
            a.phone_numbers << phone
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
