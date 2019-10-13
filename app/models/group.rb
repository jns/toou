class Group < ApplicationRecord
    
    has_many :passes, as: :recipient
    has_many :accounts, through: :memberships
    
    def to_s
        @name
    end
end
