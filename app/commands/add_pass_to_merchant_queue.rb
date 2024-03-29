class AddPassToMerchantQueue
    
    prepend SimpleCommand

    def initialize(merchant, pass, account = nil)
        @merchant = merchant
        @pass = pass
        @account = account
    end

    def call

        if @pass.can_redeem?
            
            # If MPQ already exists, return existing
            mpq = MerchantPassQueue.find_by(merchant: @merchant, pass: @pass, account: @account)
            return "%04d" % mpq.code if mpq 
    
            # otherwise create one
            code = Random.new.rand(10000)
            mpq = MerchantPassQueue.create(merchant: @merchant, pass: @pass, code: code, account: @account)
            RemovePassFromQueue.set(wait: 10.minutes).perform_later(mpq.id)
            return "%04d" % code
        elsif @pass.expired?
            errors.add(:unredeemable, "Pass is expired")
        elsif @pass.used?
            errors.add(:unredeemable, "Pass already used")
        else
            errors.add(:unredeemable, "Pass not redeemable")
        end
        
    end
end