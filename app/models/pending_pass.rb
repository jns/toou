class PendingPass < ApplicationRecord

    validates :recipient, presence: true
    
    # The Account is the owner of the pass, i.e. the person the pass was purchased for
    belongs_to :recipient, polymorphic: true
    
    # The Pass belongs to an Order.  Traverse pass.order.account to find the person who purchased the pass
    belongs_to :order
    
    # What was purchased
    belongs_to :buyable, polymorphic: true

    # Convert this pending pass into a real pass
    def createPass 
        Pass.create(recipient: recipient, order: order, buyable: buyable, message: message, value_cents: value_cents)
    end
end
