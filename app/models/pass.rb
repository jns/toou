class Pass < ActiveRecord::Base
    
    USED = "USED"
    EXPIRED = "EXPIRED"
    VALID = "VALID"
    
    # The Account is the owner of the pass, i.e. the person the pass was purchased for
    belongs_to :account
    
    # The Pass belongs to an Order.  Traverse pass.order.account to find the person who purchased the pass
    belongs_to :order
    
    # Passes redeem a promotion
    belongs_to :promotion
    
    # Passes should have an associated credit card
    has_one :card
    
    alias :recipient :account
    
    # Assign a serial number and a credit card from the pool upon creation
    before_create do
        self.serialNumber = Array.new(30){ [*'0'..'9',*'A'..'Z'].sample }.join 
    end
    
    # Passes must redeem a particular promotion
    validates_presence_of :promotion
    
    # Passes cannot be updated after creation
    before_update do 
        throw "Passes cannot be updated"
    end
    
    def purchaser
       order.account 
    end
    
    def status
       if self.used? then
           return USED
       elsif self.expired? then
           return EXPIRED
       else
           return VALID
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
