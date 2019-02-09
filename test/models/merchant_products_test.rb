require 'test_helper'

class MerchantProductsTest < ActiveSupport::TestCase
  
  test "Name delegated to product" do
    assert_equal products(:beer).name, merchant_products(:quantum_beer).name
  end
  
  test "max price delegated to product" do
    assert_equal products(:beer).max_price_cents, merchant_products(:quantum_beer).max_price_cents
  end

  test "icon delegated to product" do
    assert_equal products(:beer).icon, merchant_products(:quantum_beer).icon
  end
end
