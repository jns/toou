class AddPassToMerchantQueue
    
    prepend SimpleCommand

    def initialize(merchant, pass)
        @merchant = merchant
        @pass = pass
    end

    def call
        code = Random.new.rand(10000)
        mpq = MerchantPassQueue.create(merchant: @merchant, pass: @pass, code: code)
        RemovePassFromQueue.set(wait: 10.minutes).perform_later(mpq.id)
        return code
    end
end