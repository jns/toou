require 'test_helper'

class DeviceTest < ActiveSupport::TestCase


  test "Passcode is valid" do
    dev = Device.create(device_id: "test_device")
    dev.password = "test"
    dev.password_validity = Time.now + 1.minutes
    assert dev.password_is_valid?
  end
  
  test "Passcode is not valid" do 
    dev = Device.create(device_id: "test_device")
    dev.password = "test"
    dev.password_validity = Time.now - 1.minutes
    refute dev.password_is_valid?
  end

end
