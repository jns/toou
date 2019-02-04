class Merchant < ApplicationRecord
    
    has_many :locations
    has_many :products, through: :merchant_products
    
end
