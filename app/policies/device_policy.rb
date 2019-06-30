class DevicePolicy < ApplicationPolicy
    
    def redeem? 
       user.is_a? Device 
    end
end