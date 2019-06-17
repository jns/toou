class Transfer < ApplicationRecord
    
    belongs_to :merchant
    
    validates_presence_of :amount_cents, :stripe_transfer_id, :merchant
    
    before_update do 
		throw Exception.new("Transfers are not editable")
	end
end
