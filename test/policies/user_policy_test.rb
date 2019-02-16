require 'test_helper'

class UserPolicyTest < ActiveSupport::TestCase

	def setup
		@admin_user = users(:admin_user)
		@merchant_user = users(:quantum_user)
	end
	
	test "Anyone can new" do
		assert UserPolicy.new(nil, nil).new?
	end

	
	test "Any can login" do
		assert UserPolicy.new(nil, nil).login?
	end
end