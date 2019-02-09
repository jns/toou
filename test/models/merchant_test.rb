require 'test_helper'

class MerchantTest < ActiveSupport::TestCase
  
  test "Merchant Has Products" do
    refute_equal 0, merchants(:quantum).products.size
  end


end
