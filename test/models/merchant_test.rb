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

end
