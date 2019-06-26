class RevokePassFromMerchantQueue
    
    prepend SimpleCommand

    def initialize(merchant, pass)
        @merchant = merchant
        @pass = pass
    end

    def call
        mpq = MerchantPassQueue.find_by(merchant: @merchant, pass: @pass)
        mpq.destroy if mpq 
    end
end