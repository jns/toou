class Account < ActiveRecord::Base
    has_many :passes
    has_many :orders
    
    before_save :format_phone_number
    
    # Searches accounts by any unformatted string that resembles a phone number
    # Throws an error if the string cannot be formatted into a phone number
    def Account.search_by_phone_number(unformatted_phone_number)
        Account.find_by_phone_number(PhoneNumber.new(unformatted_phone_number).to_s)
    end
    
    def authenticate(password)
        return self.one_time_password_hash == password
    end
    
    # formats the phone number before save
    def format_phone_number
       pn = PhoneNumber.new(self.phone_number).to_s
       self.phone_number = pn
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
