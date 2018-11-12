class Account < ActiveRecord::Base
    has_many :passes
    has_many :orders
    
    def Account.search_by(recipient)
        
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
