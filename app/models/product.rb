class Product < ApplicationRecord
    
    include Buyable
    
    has_many :passes, as: :buyable
    has_many :merchant_products
    has_many :merchants, through: :merchant_products
    
   validates_presence_of :max_price_cents, :name
   
   
    def price_cents(merchant = nil)
        if merchant and can_redeem?(merchant)
            merchant_price_cents(merchant)
        else
            max_price_cents
        end
    end
    
    def can_redeem?(merchant)
       merchants.member?(merchant) 
    end
    
    def merchant_price_cents(merchant)
        product = merchant_products.find{ |mp| mp.merchant === merchant}
        if product
            product.price_cents 
        else
            0
        end
    end
end
