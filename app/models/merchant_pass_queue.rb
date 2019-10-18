class MerchantPassQueue < ApplicationRecord
    
    attr_readonly :merchant, :pass, :code, :created_at, :account
    
    before_create :check_for_duplicates
    
    belongs_to :merchant
    belongs_to :pass
    belongs_to :account
    
    def check_for_duplicates
        unless MerchantPassQueue.where(pass: pass).empty?
            throw "Pass Already Enqueued"
        end
        
        unless MerchantPassQueue.where(merchant: merchant, code: code).empty?
            throw "Code already in use"
        end
    end
end
