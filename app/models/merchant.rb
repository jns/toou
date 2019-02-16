class Merchant < ApplicationRecord
    
    belongs_to :user
    has_many :locations
    has_many :merchant_products
    has_many :products, through: :merchant_products
    has_many :charges
    
    def can_redeem?(pass)
       products.member?(pass.buyable) 
    end
end
