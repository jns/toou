class DevicePolicy < ApplicationPolicy
    
    def redeem? 
       user.is_a? Device 
    end
 
    
	class Scope < Scope
		def resolve
			scope.select{|device| device.merchant.user === user}
		end
	end
end