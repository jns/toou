class Charge < ApplicationRecord
	
	alias_attribute :source, :account
	belongs_to :account
	
	validates_presence_of :account, :amount_cents, :stripe_id
	
	before_update do 
		throw Exception.new("Charges are not editable")
	end
	
	def amount_dollars
		amount_cents/100.0
	end
	
	
end
