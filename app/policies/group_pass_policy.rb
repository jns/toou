class GroupPassPolicy < PassPolicy

    # Pass must belong to current user and be redeemable to get a code
    def get_code?
       record.recipient.accounts.member?(user) && record.can_redeem?
    end
    
    # Pass must belong to current user and be redeemable to be requested
    def request_group_pass?
        record.recipient.accounts.member?(user) && record.can_redeem?
    end

end