class Group < ApplicationRecord
    
    has_many :group_passes, as: :recipient
    has_many :memberships
    has_many :accounts, through: :memberships
    
    # Returns a hash {Product, [Pass]} tuples representing the available passes for the group
    def valid_pass_quantities
        group_passes.valid_passes.group_by{ |p| p.buyable }
    end

    def can_receive_notifications?
        false
    end 
    
    def to_s
        @name
    end
end
