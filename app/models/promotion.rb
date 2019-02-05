class Promotion < ApplicationRecord
    
    include Buyable
    
    # Valid statuses
    DRAFT = "Draft"
    ACTIVE = "Active"
    CLOSED = "Closed"
    
    validates :status, inclusion: {in: [DRAFT, ACTIVE, CLOSED]}
    validates :price_cents, numericality: {greater_than_or_equal_to: 0}
    
    has_many :passes, as: :buyable
    
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
    
    # Returns true if promotion is in draft mode
    def is_draft?
       self.status == DRAFT 
    end
    
    # Returns true if promotion is active
    def is_active?
        self.status == ACTIVE
    end
    
    # Returns true if promotion is closed
    def is_closed?
        self.status == CLOSED
    end
    
    # True if the expiration date is passed
    def expired?
        Time.now > self.end_date.at_end_of_day
    end
    
    # The promotion is purchaseable if it is active and not expired
    def can_purchase? 
       status == ACTIVE and !expired? 
    end
    
    # The purchase price of the promotion product in dollars
    def value_dollars
       price_cents/100.0
    end
    
end
