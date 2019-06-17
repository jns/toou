require 'test_helper'

class RemovePassFromQueueJobTest < ActiveJob::TestCase

  test "Job removes Merchant Pass Queue" do
    mpq = MerchantPassQueue.create(merchant: merchants(:quantum), pass: passes(:redeemable_pass), code:000)
    assert_difference 'MerchantPassQueue.count', -1 do 
      RemovePassFromQueue.perform_now(mpq.id)
    end
  end
  
  test "Job is silent if MPQ does not exist" do
    
    assert_raises ActiveRecord::RecordNotFound do
      MerchantPassQueue.find(0)
    end
    
    assert_nothing_raised do
      RemovePassFromQueue.perform_now(0)
    end
  end
end
