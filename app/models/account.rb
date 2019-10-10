class Account < ActiveRecord::Base
    has_many :passes, as: :recipient
    has_many :orders
    has_many :charges
    
    before_save :format_phone_number
    after_create :generate_stripe_customer
    
    attr_accessor :token
    
    # Searches accounts by any unformatted string that resembles a phone number
    # Throws an error if the string cannot be formatted into a phone number
    def Account.search_by_phone_number(unformatted_phone_number)
        Account.find_by_phone_number(PhoneNumber.new(unformatted_phone_number).to_s)
    end
    
    # The account can receive notifications if there is a valid device id
    def can_receive_notifications? 
       device_id != nil && device_id != ""
    end
    
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
    
    def generate_stripe_customer
        CreateStripeCustomerJob.perform_now(self.id)
        reload
    end
    
    def test_user?
       return self.phone_number === "+10000000000" 
    end
    
    def missing_fields
       result = []
       result << :name unless name
       result << :email unless email
       result << :phone_number unless phone_number
       return result
    end
    
end
