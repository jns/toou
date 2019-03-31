require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  test "admin user has admin role" do
    u = User.create(username: "Test")
    refute u.admin?
    
    u.roles << Role.admin
    assert u.admin?
  end
  
  test "merchant user has merchant role" do
    u = User.create(username: "Merchant")
    refute u.merchant?
    
    u.roles << Role.merchant
    assert u.merchant?
  end
  
  test "generate otp for device" do
    u = users(:quantum_user)
    assert_difference "Device.count",1  do
      otp = u.generate_otp_for_device("test_device")
      assert otp
      assert u.authenticate_device("test_device", otp)
    end
  end
  
  test "device otp can expire" do
    u = users(:quantum_user)
    otp = u.generate_otp_for_device("test_device")
    d = Device.find_by(device_id: "test_device")
    d.update(password_validity: Time.now)
    refute u.authenticate_device("test_device", otp)
  end
  
end
