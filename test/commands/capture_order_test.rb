require 'test_helper'

class CaptureOrderTest < ActiveSupport::TestCase
	
	def setup
    	MockStripeCharge.charges.clear
    end
	
	
	test "capture an order" do
		merchant = merchants(:quantum)
		pass = passes(:redeemable_pass)
		refute pass.used?
		
		assert_difference "Charge.count" do 
			cmd = CaptureOrder.call(merchant, pass)
			assert cmd.success?
			assert Pass.find(pass.id).used?
		end
	end
	
	test "merchant cannot redeem product" do
		merchant = merchants(:quantum)
		pass = passes(:redeemable_cupcake)
		refute pass.used?
		
		cmd = CaptureOrder.call(merchant, pass)
		refute cmd.success?
		assert_not_nil cmd.errors[:unredeemable]
	end
	
	test "cannot redeem an expired pass" do
		merchant = merchants(:quantum)
		pass = passes(:expired_beer)
		refute pass.used?
		
		cmd = CaptureOrder.call(merchant, pass)
		refute cmd.success?
		assert_not_nil cmd.errors[:unredeemable]
	end
    
    test "cannot redeem a used pass" do
		merchant = merchants(:quantum)
		pass = passes(:used_beer_pass)
		assert pass.used?
		
		cmd = CaptureOrder.call(merchant, pass)
		refute cmd.success?
		assert_not_nil cmd.errors[:unredeemable]
    end
    
    test "tester cannot redeem a pass" do
    	merchant = merchants(:test_store)
    	pass = passes(:redeemable_pass)
    	refute pass.used?
    	
    	assert merchant.products.member? pass.buyable
    	
    	cmd = CaptureOrder.call(merchant, pass)
    	refute cmd.success?
    end
    
    test "MPQ is deleted" do
    	assert false
    end
    
end