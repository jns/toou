require 'test_helper'

class MerchantTest < ActiveSupport::TestCase
  
  test "Merchant Has Products" do
    refute_equal 0, merchants(:quantum).products.size
  end

  test "Merchant is enrolled" do
    merchants.each do |m|
      if m.stripe_id
        assert m.enrolled
      else
        refute m.enrolled
      end
    end
  end
  
  test "Add a product to a merchant" do
    quantum = merchants(:quantum)
    cupcake = products(:cupcake)
    refute quantum.can_redeem_buyable?(cupcake)
    quantum.add_product(cupcake)
    quantum.reload
    assert quantum.can_redeem_buyable?(cupcake)
  end
  
  test "Remove a product from a merchant" do
    quantum = merchants(:quantum)
    beer = products(:beer)
    assert quantum.can_redeem_buyable?(beer)
    quantum.remove_product(beer)
    quantum.reload
    refute quantum.can_redeem_buyable?(beer)
  end

end
