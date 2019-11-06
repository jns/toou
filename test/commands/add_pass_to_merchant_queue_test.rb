
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
    
    test "Returns the same code if called twice" do
       cmd =AddPassToMerchantQueue.call(merchants(:cupcake_store), passes(:redeemable_cupcake))
       code = cmd.result
       cmd =AddPassToMerchantQueue.call(merchants(:cupcake_store), passes(:redeemable_cupcake))
       assert_equal code, cmd.result
    end
    
    test "Can generate a code for an expired pass" do
        cmd = AddPassToMerchantQueue.call(merchants(:quantum), passes(:expired_beer))
        assert cmd.success?
    end 
    
    test "Cannot generate a code for a used pass" do
        cmd = AddPassToMerchantQueue.call(merchants(:quantum), passes(:used_beer_pass))
        refute cmd.success?
        assert_equal ["Pass already used"], cmd.errors[:unredeemable]
    end
    
    
    test "Cannot generate a code for a used group pass" do
        cmd = AddPassToMerchantQueue.call(merchants(:quantum), passes(:used_group_beer_pass))
        refute cmd.success?
        assert_equal ["Pass already used"], cmd.errors[:unredeemable]
    end

end