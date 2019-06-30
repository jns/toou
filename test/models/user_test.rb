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
  
end
