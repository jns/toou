class Merchant < ApplicationRecord
    
    belongs_to :user
    has_many :locations
    has_many :merchant_products
    has_many :products, through: :merchant_products
    has_many :charges
    has_many :merchant_pass_queues
    
    def can_redeem?(pass)
       products.member?(pass.buyable) and !user.tester?
    end
    
    def enrolled
       stripe_id != nil
    end
    
end
