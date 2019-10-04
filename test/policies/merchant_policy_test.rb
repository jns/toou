require 'test_helper.rb'

class  MerchantPolicyTest < ActiveSupport::TestCase

	def setup
		@policy_scope = MerchantPolicy::Scope.new(users(:quantum_user), Merchant.all)
	end

	test "Scoped by current user" do
		assert @policy_scope.resolve.member?(merchants(:quantum))
	end
	
	test "Merchant user can access index" do
		assert MerchantPolicy.new(users(:quantum_user), nil).index?	
	end
	
	test "Merchant user can create" do
		assert MerchantPolicy.new(users(:quantum_user), nil).create?	
	end
	
	test "Unspecified user cannot create" do
		refute MerchantPolicy.new(nil, nil).create?	
	end
	
	test "Merchant user can show" do
		assert MerchantPolicy.new(users(:quantum_user), merchants(:quantum)).show?	
	end
	
	test "Other merchant user cannot show" do
		refute MerchantPolicy.new(users(:cupcake_user), merchants(:quantum)).show?
	end
	
	test "no authorization needed for enroll" do
		assert MerchantPolicy.new(nil, nil).enroll?	
	end
	
	test "Owning user can access dashboard link" do
		assert MerchantPolicy.new(users(:quantum_user), merchants(:quantum)).stripe_dashboard_link?	
	end
	
	test "Other users cannot access dashboard link" do
		refute MerchantPolicy.new(users(:cupcake_user), merchants(:quantum)).stripe_dashboard_link?	
	end
	
	test "Unknown users cannot access dashboard link" do
		refute MerchantPolicy.new(nil, nil).stripe_dashboard_link?	
	end
	
	test "Merchant User can access credits" do
		assert MerchantPolicy.new(users(:quantum_user), merchants(:quantum)).credits?	
	end 
	
	test "Device can access credits" do
		assert MerchantPolicy.new(devices(:quantum_device), merchants(:quantum)).credits?	
	end
	
	test "Device cannot access other merchants credits" do
		refute MerchantPolicy.new(devices(:quantum_device), merchants(:cupcake_store)).credits?	
	end
end