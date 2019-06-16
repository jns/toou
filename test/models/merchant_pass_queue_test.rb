require 'test_helper'

class MerchantPassQueueTest < ActiveSupport::TestCase

  
  test "Cannot create MPQ for same Pass twice" do
    MerchantPassQueue.create(merchant: merchants(:cupcake_store), pass: passes(:redeemable_cupcake), code: 0000)
    assert_raise do
      MerchantPassQueue.create(merchant: merchants(:cupcake_store), pass: passes(:redeemable_cupcake), code: 1111)
    end
  end
  
  test "Cannot create MPQ with same code for same merchant" do
    MerchantPassQueue.create(merchant: merchants(:cupcake_store), pass: passes(:redeemable_cupcake),  code: 0000)
    assert_raise do
      MerchantPassQueue.create(merchant: merchants(:cupcake_store), pass: passes(:redeemable_cupcake2), code: 0000)
    end
  end
end
