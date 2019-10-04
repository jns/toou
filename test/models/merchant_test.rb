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
  
  test "Merchant can authorize a device" do
    m = merchants(:quantum)  
    assert_difference 'm.devices.count' do 
      m.authorize_device("A device")
    end
  end 
  
  test "Merchant can Deauthorize device" do
    m = merchants(:quantum)
    device =m.authorize_device("test_device")
    assert_not_nil Device.find_by(merchant: m, device_id: "test_device")
    assert m.deauthorize_device(device.id)
    assert_nil Device.find_by(merchant: m, device_id: "test_device")
  end
  
  test "Merchant cannot deauthorize another merchant's device" do
    m = merchants(:quantum)
    m.authorize_device("test_device")
    assert_not_nil Device.find_by(merchant: m, device_id: "test_device")
    refute merchants(:cupcake_store).deauthorize_device("test_device")
    assert_not_nil Device.find_by(merchant: m, device_id: "test_device")
  end 
  
  test "Redeem merchant credits" do
    m = merchants(:quantum)
    assert_equal 1, m.charges.count
  end

end
