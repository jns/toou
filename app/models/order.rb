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
end
