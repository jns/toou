class MobilePhoneAccount < Account
   
    before_save { authentication_method = AUTHX_OTP }
    before_save :format_phone_number

    # Searches accounts by any unformatted string that resembles a phone number
    # Throws an error if the string cannot be formatted into a phone number
    def MobilePhoneAccount.search_by_phone_number(unformatted_phone_number)
        MobilePhoneAccount.find_by_phone_number(PhoneNumber.new(unformatted_phone_number).to_s)
    end    
    
    # The account can receive notifications if there is a valid device id
    def can_receive_notifications? 
       device_id != nil && device_id != ""
    end
    
    # Authenticates using the one time password
     def authenticate(password)
        if test_user?
           password === "000000" 
        else
            BCrypt::Password.new(self.one_time_password_hash) == password and self.one_time_password_validity > Time.new
        end
    end
    
    # formats the phone number before save
    def format_phone_number
       pn = PhoneNumber.new(self.phone_number).to_s
       self.phone_number = pn
    end
    
    # Generates a one time passcode for accounts to authenticate
    def generate_otp
        otp = rand(100000...999999).to_s
        self.one_time_password_hash = BCrypt::Password.create(otp)
        self.one_time_password_validity = Time.new + 10.minutes
        if self.save
            otp
        else
            raise "Error generating password"
        end
    end

    def test_user?
       return self.phone_number === "+10000000000" 
    end
    
end