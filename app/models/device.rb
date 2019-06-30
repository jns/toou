class Device < ApplicationRecord
	has_secure_password
    belongs_to :merchant
    
    validates_presence_of :merchant
    
    def password_is_valid? 
    	password_validity > Time.now	
    end
    
end
