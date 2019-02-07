class Role < ApplicationRecord
    
    ADMIN_STRING = "Admin"
    MERCHANT_STRING = "Merchant"
    
    def Role.admin 
       Role.find_or_create_by(name: ADMIN_STRING) 
    end
    
    def Role.merchant
       Role.find_or_create_by(name: MERCHANT_STRING) 
    end
    
    validates :name, inclusion: {in: [ADMIN_STRING, MERCHANT_STRING]}
    validates :name, uniqueness: true
    
    has_and_belongs_to_many :users
end
