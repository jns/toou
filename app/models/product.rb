class Product < ApplicationRecord
    
    include Buyable
    
    has_many :passes, as: :buyable
    has_many :merchants, through: :merchant_products
   
    def price_cents
        max_price_cents
    end
    
end
