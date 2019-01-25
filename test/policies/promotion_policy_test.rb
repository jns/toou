require 'test_helper'

class PromotionPolicyTest < ActiveSupport::TestCase
  
  def setup
    @admin = admin_accounts(:admin)
  end
  
  def test_scope
  end

  def test_new
    assert PromotionPolicy.new(@admin, nil).new?
    refute PromotionPolicy.new(nil, nil).new?
  end
  
  test "authorize show for draft if authenticated" do
    assert PromotionPolicy.new(@admin, promotions(:draft)).show?
  end
  
  test "do not authorize show for draft if unauthenticated" do
    refute PromotionPolicy.new(nil, promotions(:draft)).show?
  end
  
  test "authorize show for closed if authenticated" do
    assert PromotionPolicy.new(@admin, promotions(:expired)).show?
  end 
  
  test "do not authorize show for closed if unauthenticated" do
    refute PromotionPolicy.new(nil, promotions(:expired)).show?
  end
  
  test "authorize show for active" do
    assert PromotionPolicy.new(nil, promotions(:active)).show?
    assert PromotionPolicy.new(@admin, promotions(:active)).show?
  end

  def test_create
    assert PromotionPolicy.new(@admin, nil).create?
    refute PromotionPolicy.new(nil, nil).create?
  end

  def test_update
    assert PromotionPolicy.new(@admin, promotions(:draft)).update?
    refute PromotionPolicy.new(nil, promotions(:draft)).update?
    
    refute PromotionPolicy.new(nil, promotions(:expired)).update?
    refute PromotionPolicy.new(@admin, promotions(:expired)).update?
    
    refute PromotionPolicy.new(nil, promotions(:active)).update?
    refute PromotionPolicy.new(@admin, promotions(:active)).update?
  end

  def test_destroy
    assert PromotionPolicy.new(@admin, promotions(:draft)).destroy?
    refute PromotionPolicy.new(nil, promotions(:draft)).destroy?
    
    refute PromotionPolicy.new(nil, promotions(:expired)).destroy?
    refute PromotionPolicy.new(@admin, promotions(:expired)).destroy?
    
    refute PromotionPolicy.new(nil, promotions(:active)).destroy?
    refute PromotionPolicy.new(@admin, promotions(:active)).destroy?
  end
end
