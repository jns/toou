require 'test_helper'

class PassPolicyTest < ActiveSupport::TestCase
  
  def setup
    @admin_policy = PassPolicy.new(admin_accounts(:admin), passes(:distant_future))
  end
  
  def test_scope
  end

  def test_show
    assert @admin_policy.show?
  end

  def test_create
    refute @admin_policy.create?
  end

  def test_update
    refute @admin_policy.update?
  end

  def test_destroy
    refute @admin_policy.destroy?
  end
end
