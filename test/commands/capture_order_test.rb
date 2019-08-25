require 'test_helper'

class CaptureOrderTest < ActiveSupport::TestCase
	
	def setup
    	MockStripeCharge.charges.clear
    end
	
	def get_code(merchant, pass)
		code = Random.new.rand(10000)
		mpq = MerchantPassQueue.create(merchant: merchant, pass: pass, code: code)
		return "%04d" % code
	end
	
	test "capture an order results in used pass" do
		merchant = merchants(:quantum)
		pass = passes(:redeemable_pass)
		refute pass.used?
		
		code = get_code(merchant, pass)
		cmd = CaptureOrder.call(merchant, code)
		assert cmd.success?
		assert Pass.find(pass.id).used?
	end
	
	test "capturing order creates a transfer" do
		merchant = merchants(:quantum)
		pass = passes(:redeemable_pass)
		assert_nil pass.transfer_stripe_id
		assert_nil pass.transfer_amount_cents
		
		code = get_code(merchant, pass)
		cmd = CaptureOrder.call(merchant, code)
		assert cmd.success?
		
		pass.reload
		assert_not_nil pass.transfer_stripe_id
		assert_equal pass.buyable.price(:cents), pass.transfer_amount_cents
	end
	
	test "merchant cannot redeem product does not mark pass used" do
		merchant = merchants(:quantum)
		pass = passes(:redeemable_cupcake)
		refute pass.used?
		
		code = get_code(merchant, pass)
		cmd = CaptureOrder.call(merchant, code)
		refute cmd.success?
		assert_not_nil cmd.errors[:unredeemable]
		
		# Ensure pass is still usable and no charges created
		pass.reload
		refute pass.used?
		
	end
	
	test "unredeemable pass does not result in transfer" do
		merchant = merchants(:quantum)
		pass = passes(:redeemable_cupcake)
		refute pass.used?
		
		code = get_code(merchant, pass)
		cmd = CaptureOrder.call(merchant, code)
		refute cmd.success?
		assert_not_nil cmd.errors[:unredeemable]
		
		# Ensure pass is still usable and no charges created
		pass.reload
		assert_nil pass.transfer_stripe_id
		assert_nil pass.transfer_amount_cents
	end
	
	test "can redeem an expired pass" do
		merchant = merchants(:quantum)
		pass = passes(:expired_beer)
		refute pass.used?
		
		code = get_code(merchant, pass)
		cmd = CaptureOrder.call(merchant, code)
		assert cmd.success?
	end
    
    test "cannot redeem a used pass" do
		merchant = merchants(:quantum)
		pass = passes(:used_beer_pass)
		assert pass.used?
		
		code = get_code(merchant, pass)
		cmd = CaptureOrder.call(merchant, code)
		refute cmd.success?
		assert_not_nil cmd.errors[:unredeemable]
    end
    
    test "tester cannot redeem a pass" do
    	merchant = merchants(:test_store)
    	pass = passes(:redeemable_pass)
    	refute pass.used?
    	
    	assert merchant.products.member? pass.buyable
    	
    	code = get_code(merchant, pass)
    	cmd = CaptureOrder.call(merchant, code)
    	refute cmd.success?
    end
    
    test "MPQ is deleted upon redemption" do
    	merchant = merchants(:quantum)
		pass = passes(:redeemable_pass)
		
		code = get_code(merchant, pass)
		assert MerchantPassQueue.find_by(merchant: merchant, code: code)
		cmd = CaptureOrder.call(merchant, code)
		assert cmd.success?
		assert_nil MerchantPassQueue.find_by(merchant: merchant, code: code)	
    end
    
end