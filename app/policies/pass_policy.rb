class PassPolicy < AdminPolicy
    
    def pass?
        record.account == user
    end
    
    # Pass must belong to current user and be redeemable to get a code
    def get_code?
       record.account == user && record.can_redeem?
    end
end
