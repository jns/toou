require 'test_helper'

class GroupPolicyTest < ActiveSupport::TestCase


  test "policy scope excludes private groups" do
    assert GroupPolicy::Scope.new(accounts(:active_duty), Group).resolve.all?
  end
  
end
