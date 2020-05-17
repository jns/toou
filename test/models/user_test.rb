require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "Can create a new user" do 
  end
  
  test "admin user has admin role" do
    u = User.create(username: "Test")
    assert_not_nil u.id
    refute u.admin?
    
    u.roles << Role.admin
    assert u.admin?
  end
  
  
  test "merchant user has merchant role" do
    u = User.create(username: "Merchant")
    assert_not_nil u.id
    refute u.merchant?
    
    u.roles << Role.merchant
    assert u.merchant?
  end
  
  
  test "It should find mobilePhoneAccount for an existing user with phone number only" do 
    acct = accounts(:josh)
    assert_equal acct,  User.find_or_create_mobile_phone_account(acct.phone_number, nil, nil)
  end
  
  
end
