class Device < ApplicationRecord
	
	belongs_to :merchant

    validates_presence_of :merchant
    
end
