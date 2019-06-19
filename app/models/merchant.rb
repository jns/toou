class Merchant < ApplicationRecord
    
    belongs_to :user
    has_many :locations
    has_many :merchant_products
    has_many :products, through: :merchant_products
    has_many :merchant_pass_queues
    
    scope :enrolled, ->{ where('stripe_id is not null') }
    
    def can_redeem?(pass)
       products.member?(pass.buyable) and !user.tester?
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
