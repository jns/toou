class Pass < ActiveRecord::Base
    
    # The Account is the owner of the pass, i.e. the person the pass was purchased for
    belongs_to :account
    
    # The Pass belongs to an Order.  Traverse pass.order.account to find the person who purchased the pass
    belongs_to :order
    
    alias :recipient :account
    
    def purchaser
       order.account 
    end
    
    
end
