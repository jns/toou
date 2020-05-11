class PassPolicy < AdminPolicy
    
    def pass?
        recipient = record.recipient
        if recipient.is_a? Group
            recipient.accounts.member? user
        elsif recipient.is_a? Account
            recipient == user
        else
            false
        end
    end
    
    # Pass must belong to current user and be redeemable to get a code
    def get_code?
       record.recipient == user
    end
    
    # Admin can update a pass
    # def update?
    #     user and user.admin?
    # end
end
