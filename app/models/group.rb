class Group < ApplicationRecord
    
    has_many :passes, as: :recipient
    has_many :accounts, through: :memberships
    
end
