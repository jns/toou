
require 'test_helper'

class AddPassToMerchantQueueTest < ActiveSupport::TestCase

    include ActiveJob::TestHelper

    def setup()
    end
    
    test "Command schedules a destroy job" do
        assert_enqueued_with(job: RemovePassFromQueue) do
            AddPassToMerchantQueue.call(merchants(:cupcake_store), passes(:redeemable_cupcake))
        end
    end

    test "Can generate a code for a valid pass" do
        cmd = AddPassToMerchantQueue.call(merchants(:cupcake_store), passes(:redeemable_cupcake))
        assert cmd.success?
        assert cmd.result =~ /\d{4}/
    end 
    
    test "Cannot generate a code for an expired pass" do
        cmd = AddPassToMerchantQueue.call(merchants(:quantum), passes(:expired_beer))
        refute cmd.success?
    end 
    
    test "Cannot generate a code for a used pass" do
        cmd = AddPassToMerchantQueue.call(merchants(:quantum), passes(:used_beer_pass))
        refute cmd.success?
    end

end