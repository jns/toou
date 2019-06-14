class PassPolicy < AdminPolicy
    
    def pass?
        record.account == user
    end
end
