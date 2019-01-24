class Promotion < ApplicationRecord
    
    # Valid statuses
    DRAFT = "Draft"
    ACTIVE = "Active"
    CLOSED = "Closed"
    
    validates :status, inclusion: {in: [DRAFT, ACTIVE, CLOSED]}
    validates :value_cents, numericality: {greater_than_or_equal_to: 0}
    
    has_many :passes
    
    # Set the status to draft if it isn't set
    before_validation do 
        self.status ||= DRAFT
    end
    
    # Call to place the promotion into an active state
    # Active promotions are published and purchaseable
    # assuming they are not expired and have remaining quantity
    def activate
       self.status=ACTIVE 
       self.save
    end
    
    # Call to place the promotion into a closed state
    # Closed promotions are not published and are not purchaseable
    def close
        self.status=CLOSED
        self.save
    end
    
    # True if the expiration date is passed
    def expired?
        Time.now > self.end_date.at_end_of_day
    end
    
    # The remaining quantity available
    def remaining_quantity
        self.quantity - passes.size
    end
    
    # The promotion is purchaseable if it is active and not expired
    def can_purchase? 
       status == ACTIVE and !expired? and remaining_quantity > 0
    end
    
    # The purchase price of the promotion product in dollars
    def value_dollars
       value_cents/100.0
    end
    
end
