require 'test_helper'

class RevokePassFromMerchantQueueTest < ActiveSupport::TestCase

    include ActiveJob::TestHelper

    test "Remove code from merchant pass queue" do
        m = merchants(:cupcake_store)
        p = passes(:redeemable_cupcake)
        cmd =AddPassToMerchantQueue.call(m, p)
        code = cmd.result  
        mpq = MerchantPassQueue.find_by(merchant: m, pass: p)
        assert_equal code.to_i, mpq.code
        cmd = RevokePassFromMerchantQueue.call(m,p)
        assert cmd.success?
        assert_nil MerchantPassQueue.find_by(merchant: m, pass: p)
    end

end