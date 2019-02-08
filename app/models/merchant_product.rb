class MerchantProduct < ApplicationRecord
    belongs_to :merchant
    belongs_to :product
    
    def name
        product.name
    end
    
    def icon
        product.icon
    end
    
    def max_price_cents
        product.max_price_cents
    end
end
