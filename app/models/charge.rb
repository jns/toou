class Charge < ApplicationRecord
	
	alias_attribute :source, :account
	belongs_to :account
	
	alias_attribute :destination, :merchant
	belongs_to :merchant
	
	validates_presence_of :account, :merchant, :source_amount_cents, :destination_amount_cents, :stripe_id
	
	before_update do 
		throw Exception.new("Charges are not editable")
	end
	
end
