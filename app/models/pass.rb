class Pass < ActiveRecord::Base
    
    
    # The Account is the owner of the pass, i.e. the person the pass was purchased for
    belongs_to :account
    
    # The Pass belongs to an Order.  Traverse pass.order.account to find the person who purchased the pass
    belongs_to :order
    
    alias :recipient :account
    
    def purchaser
       order.account 
    end
    
    def status
       if self.used? then
           return "USED"
       elsif self.expired? then
           return "EXPIRED"
       else
           return "VALID"
       end
    end
    
    def expired? 
        return (Time.new - self.expiration) > 0
    end
    
    def not_expired? 
       return !expired?
    end
    
    def used?
       return (self.proof_of_purchase != nil) 
    end
    
    def not_used?
       return !used? 
    end
    
end
