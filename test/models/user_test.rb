require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "Can create a new user" do 
  end
  
  test "admin user has admin role" do
    u = User.create(username: "Test", email: "test@test.com", password: "password")
    assert_not_nil u.id
    refute u.admin?
    
    u.roles << Role.admin
    assert u.admin?
  end
  
  
  test "merchant user has merchant role" do
    u = User.create(username: "Merchant", email: "merchant@merchant.com", password: "password")
    assert_not_nil u.id
    refute u.merchant?
    
    u.roles << Role.merchant
    assert u.merchant?
  end
  
end
