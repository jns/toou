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

  
  test "generate otp for device" do
    m = merchants(:quantum)
    assert_difference "Device.count",1  do
      otp = m.generate_otp_for_device("test_device")
      assert otp
      assert m.authenticate_device("test_device", otp)
    end
  end
  
  test "device otp can expire" do
    m = merchants(:quantum)
    otp = m.generate_otp_for_device("test_device")
    d = Device.find_by(device_id: "test_device")
    d.update(password_validity: Time.now)
    refute m.authenticate_device("test_device", otp)
  end
  
  test "Test merchant can authenticate" do
    
    m = merchants(:test_store)
    assert_equal User::TEST_USERNAME, m.user.username
    otp = m.generate_otp_for_device("a_device")
    assert_equal User::TEST_PASSCODE, otp
    assert m.authenticate_device("a_device", User::TEST_PASSCODE)
    
  end
  
  test "Merchant can Deauthorize device" do
    m = merchants(:quantum)
    m.generate_otp_for_device("test_device")
    assert_not_nil Device.find_by(device_id: "test_device")
    assert m.deauthorize_device("test_device")
    assert_nil Device.find_by(device_id: "test_device")
  end
  
  test "Merchant cannot deauthorize another merchant's device" do
    m = merchants(:quantum)
    m.generate_otp_for_device("test_device")
    assert_not_nil Device.find_by(device_id: "test_device")
    refute merchants(:cupcake_store).deauthorize_device("test_device")
    assert_not_nil Device.find_by(device_id: "test_device")
  end 

end
