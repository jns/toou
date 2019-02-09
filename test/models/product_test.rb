require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  
  test "merchant can redeem" do
    assert products(:beer).can_redeem?(merchants(:quantum))
  end
  
  test "merchant product price" do
    qb = merchant_products(:quantum_beer)
    assert_equal qb.price_cents, products(:beer).merchant_price_cents(merchants(:quantum))
  
    assert_equal qb.price_cents, products(:beer).price_cents(merchants(:quantum))
  end
  
  test "default product price" do
    assert_equal  products(:beer).max_price_cents, products(:beer).price_cents
  end
  
  test "max price conversion" do
    assert_equal products(:beer).max_price_cents/100.0, products(:beer).price(:dollars)
  end
  
  test "merchant price conversion" do
    assert_equal products(:beer).price_cents(merchants(:quantum))/100.0, products(:beer).price(:dollars, merchants(:quantum))
  end
end
