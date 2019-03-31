class Device < ApplicationRecord
	has_secure_password
    belongs_to :user
    
    validates_presence_of :user
    
    def password_is_valid? 
    	password_validity > Time.now	
    end
end
