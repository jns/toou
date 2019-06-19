class Order < ActiveRecord::Base
    
    FAILED_STATUS = "FAILED"
    OK_STATUS = "OK"
    
    # The customer that made the purchase
    belongs_to :account
    
    # The recipients of the passes
    has_many :passes
    
    before_create do 
       self.status = OK_STATUS 
    end
    
    def recipients 
       passes.collect{|p| p.account} 
    end
    
    def pass_status
       valid = 0
       used = 0
       expired = 0
       passes.each{|p| 
            used += 1 if p.used?
            expired += 1 if p.expired?
            valid += 1 if p.can_redeem?
       }
       result = ""
       result += "#{valid} VALID " if valid > 0
       result += "#{used} USED " if used > 0
       result += "#{expired} EXPIRED" if expired > 0
       return result
    end
end
