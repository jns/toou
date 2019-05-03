class User < ApplicationRecord
    
    TEST_USERNAME = "tester"
    TEST_PASSCODE = "000000"
    
    has_secure_password
    has_and_belongs_to_many :roles
    has_many :devices
    
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
           Merchant.find_by(user: self)
       else
           nil
       end
    end
    
    def authenticate_device(device, passcode) 
        
        dev = device.is_a?(Device) ? device : Device.find_by(device_id: device)
        if devices.member?(dev)
            dev.authenticate(passcode) and dev.password_is_valid?
        else
            false
        end
    end
    
    # Deauthorizes the specified device if the device belongs to this user
    # returns true if successful, false otherwise
    def deauthorize_device(device)
        
        dev = device.is_a?(Device) ? device : Device.find_by(device_id: device)    
        if dev and dev.user and dev.user == self 
            dev.destroy 
            return true
        else
            return false
        end
        
        
    end 
    
    # Generates a single use passcode for 
    # The provided device 
    def generate_otp_for_device(device)
        dev = device.is_a?(Device) ? device : Device.find_or_create_by(device_id: device)
        if dev.user and dev.user != self
            raise "Device in use by another user"
        else
            devices << dev
        end
        
        otp = if tester? 
           TEST_PASSCODE 
        else
            rand(100000...999999).to_s
        end
        
        dev.password = otp
        dev.password_validity = Time.new + 10.minutes
        
        if dev.save
            otp
        else
            raise "Error generating password"
        end 
    end
end
