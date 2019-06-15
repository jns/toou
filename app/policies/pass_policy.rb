class PassPolicy < AdminPolicy
    
    def pass?
        record.account == user
    end
    
    # Pass must belong to current user to get a code
    def get_code?
       record.account == user 
    end
end
