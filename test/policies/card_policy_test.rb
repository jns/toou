require 'test_helper'

class CardPolicyTest < ActiveSupport::TestCase
  
  def setup
    @admin = admin_accounts(:admin)
    @card = cards(:one)
  end
  
  def test_scope
  end

  test "show card to admin only" do
    assert CardPolicy.new(@admin, @card).show?
    refute CardPolicy.new(nil, @card).show?
  end

  test "only admin can create card" do
    assert CardPolicy.new(@admin, @card).create?
    refute CardPolicy.new(nil, @card).create?
  end

  test "only admin can update card" do
    assert CardPolicy.new(@admin, @card).update?
    refute CardPolicy.new(nil, @card).update?
  end

  test "only admin can destroy card" do
    assert CardPolicy.new(@admin, @card).destroy?
    refute CardPolicy.new(nil, @card).destroy?
  end
end
