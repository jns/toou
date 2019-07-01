require 'test_helper.rb'

class  DevicePolicyTest < ActiveSupport::TestCase

	def setup
		@policy_scope = DevicePolicy::Scope.new(users(:quantum_user), Device.all)
	end

    test "Policy Scope returns device" do
        assert_equal 1, @policy_scope.resolve.count
    end
end