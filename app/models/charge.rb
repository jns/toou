class Charge < ApplicationRecord
	
	alias_attribute :source, :account
	belongs_to :account
	
	alias_attribute :destination, :merchant
	belongs_to :merchant
	
	before_update do 
		throw "Charges are not editable"
	end
	
end
