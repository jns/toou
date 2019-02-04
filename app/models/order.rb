class Order < ActiveRecord::Base
    
    # The customer that made the purchase
    belongs_to :account
    
    # The recipients of the passes
    has_many :passes
    
    # What was purchased
    belongs_to :buyable, polymorphic: true
    
    def recipients 
       passes.collect{|p| p.account} 
    end
end
