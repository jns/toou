class AddPassToMerchantQueue
    
    prepend SimpleCommand

    def initialize(merchant, pass)
        @merchant = merchant
        @pass = pass
    end

    def call

        if @pass.can_redeem? 
            code = Random.new.rand(10000)
            mpq = MerchantPassQueue.create(merchant: @merchant, pass: @pass, code: code)
            RemovePassFromQueue.set(wait: 10.minutes).perform_later(mpq.id)
            return code
        elsif @pass.expired?
            errors.add(:unredeemable, "Pass is expired")
        elsif @pass.used?
            errors.add(:unredeemable, "Pass already used")
        else
            errors.add(:unredeemable, "Pass not redeemable")
        end
        
    end
end