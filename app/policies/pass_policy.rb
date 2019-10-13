class PassPolicy < AdminPolicy
    
    def pass?
        record.recipient == user
    end
    
    # Pass must belong to current user and be redeemable to get a code
    def get_code?
       record.recipient == user && record.can_redeem?
    end
    
    # Admin can update a pass
    # def update?
    #     user and user.admin?
    # end
end
