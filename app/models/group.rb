class Group < ApplicationRecord
    
    has_many :group_passes, as: :recipient
    has_many :memberships
    has_many :accounts, through: :memberships
    
    def to_s
        @name
    end
end
