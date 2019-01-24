require 'test_helper'

class PromotionTest < ActiveSupport::TestCase
  
  test "assert draft on create" do
    c = Promotion.create(name: "Test")
    assert_equal Promotion::DRAFT, c.status
  end 
  
  test "expired" do
     assert promotions(:expired).expired?
  end
  
  test "not expired" do
    refute promotions(:not_expired).expired?
  end
  
  test "activate" do
    promotions(:not_expired).activate
    assert_equal Promotion::ACTIVE, promotions(:not_expired).status
  end
  
  test "close" do
    promotions(:not_expired).close
    assert_equal Promotion::CLOSED, promotions(:not_expired).status
  end
  
end
