class Role < ApplicationRecord
    
    ADMIN = "Admin"
    MERCHANT = "Merchant"
    
    validates :name, inclusion: {in: [ADMIN, MERCHANT]}
    validates :name, uniqueness: true
    
    has_and_belongs_to_many :users
end
