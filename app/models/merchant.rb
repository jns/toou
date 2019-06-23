class Merchant < ApplicationRecord
    
    belongs_to :user
    has_many :locations
    has_many :merchant_products
    has_many :products, through: :merchant_products
    has_many :merchant_pass_queues
    
    scope :enrolled, ->{ where('stripe_id is not null') }
    
    def add_product(product)
        unless can_redeem_buyable?(product)
            MerchantProduct.create(merchant: self, product: product)
        end
    end
    
    def remove_product(product)
        mp = MerchantProduct.find_by(merchant: self, product: product)
        mp.destroy if mp
    end
    
    def can_redeem?(pass)
       products.member?(pass.buyable) and !user.tester?
    end
    
    def can_redeem_buyable?(buyable)
       products.member?(buyable) 
    end
    
    def enrolled
       stripe_id != nil
    end
    
    def charges
        Pass.where(merchant: self).collect{|p| 
            {id: p.id, created_at: p.transfer_created_at, amount_cents: p.transfer_amount_cents}
        }
    end
    
end
