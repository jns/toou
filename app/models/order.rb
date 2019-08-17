class Order < ActiveRecord::Base
    
    FAILED_STATUS = "FAILED"
    OK_STATUS = "OK"
    PENDING_STATUS = "PENDING"
    
    # the payment intent
    attr_accessor :payment_intent
    
    # The customer that made the purchase
    belongs_to :account
    
    # The recipients of the passes
    has_many :passes
    
    scope :today, ->{ where(created_at: (Time.now.beginning_of_day)..Time.now )}
    scope :yesterday, -> {where(created_at: (Time.now - 1.day).beginning_of_day..(Time.now-1.day).end_of_day)}
    
    before_create do 
       self.status = OK_STATUS 
    end
    
    def recipients 
       passes.collect{|p| p.account} 
    end
    
    def redeemable_passes
       passes.select{|p| p.can_redeem?} 
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
    
    def fee
       charge_amount_cents - commitment_amount_cents 
    end
end
