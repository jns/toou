require 'test_helper'

class GroupPassPolicyTest < ActiveSupport::TestCase

  test "allow group member to get code" do
    assert GroupPassPolicy.new(accounts(:active_duty), passes(:redeemable_by_army)).get_code?  
  end 
  
  
  test "deny non-group member to get code" do
    refute GroupPassPolicy.new(accounts(:beer_lover), passes(:redeemable_by_army)).get_code?
  end 

end