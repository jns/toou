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
	
	test "capture an order" do
		merchant = merchants(:quantum)
		pass = passes(:redeemable_pass)
		refute pass.used?
		
		assert_difference "Charge.count" do
			code = get_code(merchant, pass)
			cmd = CaptureOrder.call(merchant, code)
			assert cmd.success?
			assert Pass.find(pass.id).used?
		end
	end
	
	test "merchant cannot redeem product" do
		merchant = merchants(:quantum)
		pass = passes(:redeemable_cupcake)
		refute pass.used?
		
		code = get_code(merchant, pass)
		cmd = CaptureOrder.call(merchant, code)
		refute cmd.success?
		assert_not_nil cmd.errors[:unredeemable]
	end
	
	test "cannot redeem an expired pass" do
		merchant = merchants(:quantum)
		pass = passes(:expired_beer)
		refute pass.used?
		
		code = get_code(merchant, pass)
		cmd = CaptureOrder.call(merchant, code)
		refute cmd.success?
		assert_not_nil cmd.errors[:unredeemable]
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
    
    test "MPQ is deleted" do
    	merchant = merchants(:quantum)
		pass = passes(:redeemable_pass)
		
		code = get_code(merchant, pass)
		assert MerchantPassQueue.find_by(merchant: merchant, code: code)
		cmd = CaptureOrder.call(merchant, code)
		assert cmd.success?
		assert_nil MerchantPassQueue.find_by(merchant: merchant, code: code)	
    end
    
end