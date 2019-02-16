require 'test_helper'

class PassTest < ActiveSupport::TestCase

  test "Pass status is expired if past expiration date" do
      assert_equal Pass::EXPIRED, passes(:expired).status
  end
  
  test "Pass status is valid if in the distant future" do
      assert_equal Pass::VALID, passes(:distant_future).status
  end

  test "Pass is used if it has a charge" do
    assert_not_nil passes(:used_beer_pass).charge
    assert passes(:used_beer_pass).used?
    refute passes(:used_beer_pass).not_used?
    refute passes(:used_beer_pass).can_redeem?
    refute passes(:used_beer_pass).expired?
  end
  
  test "Pass is not used if it does not have a charge" do
    assert_nil passes(:redeemable_pass).charge
    refute passes(:redeemable_pass).used?
    assert passes(:redeemable_pass).not_used?
    assert passes(:redeemable_pass).can_redeem?
    refute passes(:redeemable_pass).expired?
  end
  
  
  
end
