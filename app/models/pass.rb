class Pass < ActiveRecord::Base
    
    attr_readonly :serial_number, :expiration, :created_at, :recipient, :order, :buyable, :value
    
    USED = "USED"
    EXPIRED = "EXPIRED"
    VALID = "VALID"
    
    # The Account is the owner of the pass, i.e. the person the pass was purchased for
    # belongs_to :account
    
    # The Pass belongs to an Order.  Traverse pass.order.account to find the person who purchased the pass
    belongs_to :order
    
    # What was purchased
    belongs_to :buyable, polymorphic: true
    
    # When a pass is used, a charge is created
    # DEPRECATED - Will through an error after running migration in 4c98d69ce
    belongs_to :charge
    
    # A pass is redeemed by a merchant
    belongs_to :merchant
    
    belongs_to :recipient, polymorphic: true
    
    scope :valid_passes, ->{where("transfer_stripe_id is null and expiration > '#{Time.now.to_formatted_s(:db)}'")}
    
    # Assign a serial number and a credit card from the pool upon creation
    before_create do
        self.serial_number = Array.new(30){ [*'0'..'9',*'A'..'Z'].sample }.join 
        self.expiration = Date.today + 10.years
    end
    
    # Passes must be part of an order
    validates_presence_of :order, :buyable, :recipient
    
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
    
    def can_redeem?
       status === VALID 
    end
    
    def expired? 
        return false  
    end
    
    def not_expired? 
       return !expired?
    end
    
    def used?
       return (self.transfer_stripe_id != nil) 
    end
    
    def not_used?
       return !used? 
    end
    
    def barcode_payload
       self.serial_number[0..5] 
    end
    
    def value_dollars
       self.value_cents / 100.0 
    end
    
end
