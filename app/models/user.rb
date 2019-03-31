class User < ApplicationRecord
    has_secure_password
    has_and_belongs_to_many :roles
    
    def admin?
       roles.member?(Role.admin) 
    end
    
    def merchant?
       roles.member?(Role.merchant) 
    end
    
    def merchant
       if merchant?
           Merchant.find_by(user: self)
       else
           nil
       end
    end
    
    def generate_otp_for_device(device)
        otp = rand(100000...999999).to_s
        self.one_time_password_hash = BCrypt::Password.create(otp)
        self.one_time_password_validity = Time.new + 10.minutes
        if self.save
            otp
        else
            raise "Error generating password"
        end 
    end
end
