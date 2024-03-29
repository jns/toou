require 'test_helper'

class PassPolicyTest < ActiveSupport::TestCase
  
  def setup
  end
  
  test "recipient can get pass" do
    pass = passes(:distant_future)
    account = pass.recipient
    assert PassPolicy.new(account, pass).pass?
  end
  
  test "thief cannot get pass" do
    pass = passes(:distant_future)
    accounts.each do |a|
      if pass.recipient == a 
        assert PassPolicy.new(a, pass).pass?
      else
        refute PassPolicy.new(a, pass).pass?
      end
    end
  end
  
  test "admin scope is all" do
    assert_equal Pass.all.count, PassPolicy::Scope.new(users(:admin_user), Pass.all).resolve.count
  end
  
  test "merchant scope is none" do
    assert_equal 0, PassPolicy::Scope.new(users(:quantum_user), Pass.all).resolve.count
  end
  
  test "admin can index" do
    assert PassPolicy.new(users(:admin_user), nil).index?
  end

  test "merchant cannot index" do
    refute PassPolicy.new(users(:quantum_user), nil).index?
  end

  test "admin show any" do
    assert PassPolicy.new(users(:admin_user), nil).show?
  end

  test "merchant show none" do
    refute PassPolicy.new(users(:quantum_user),nil).show?  
  end
  
  test "deny create" do
    refute PassPolicy.new(nil, nil).create?
    refute PassPolicy.new(users(:quantum_user), nil).create?
    refute PassPolicy.new(users(:admin_user), nil).create?
  end

  test "deny update" do 
    refute PassPolicy.new(nil, nil).update?
    refute PassPolicy.new(users(:quantum_user), nil).update?
    refute PassPolicy.new(users(:admin_user), nil).update?
  end

  test "deny destroy" do
    refute PassPolicy.new(nil, nil).destroy?
    refute PassPolicy.new(users(:quantum_user), nil).destroy?
    refute PassPolicy.new(users(:admin_user), nil).destroy?
  end
  
  test "allow owner to get code" do
    assert PassPolicy.new(accounts(:new_person_2), passes(:redeemable_pass)).get_code?
  end
  
  
  test "deny thief to get code" do
    refute PassPolicy.new(accounts(:beer_lover), passes(:redeemable_pass)).get_code?
  end
  
 
end
