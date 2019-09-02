require 'test_helper'

class InitiateOrderTest < ActiveSupport::TestCase
   
    def setup
        MockStripePaymentIntent.intents.clear
        accounts(:josh).orders.clear   
        @promo = promotions(:generic)
    end
    
   test "Order Succeeds" do
       acct = accounts(:josh)
       recipients = [accounts(:pete).phone_number]
       source = "pm_12345"
       message = "test"
       product = products(:beer)
       
       assert_difference 'MockStripePaymentIntent.intents.count' do
           cmd = InitiateOrder.call(acct, source, recipients, message, product)
           assert cmd.success?
           order = cmd.result
           intent = MockStripePaymentIntent.retrieve(order.charge_stripe_id)
           assert_equal Order::OK_STATUS, order.status
           assert_equal intent, order.payment_intent
           assert_equal 1, order.passes.count
           pass = order.passes.first
           assert_equal accounts(:pete), pass.account
           assert_equal product, pass.buyable
           assert_equal product.max_price_cents, pass.value_cents
           assert_equal message, pass.message
           assert_equal MockStripePaymentIntent.intents.last.id, intent.id
           assert_equal order.commitment_amount_cents, product.max_price_cents
       end
   end
   
   test "Card Declined" do
        acct = accounts(:josh)
        recipients = [accounts(:pete).phone_number]
        source = MockStripePaymentIntent::INVALID_PAYMENT
        message = "test"
        product = products(:beer)
        
        assert_no_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(acct, source, recipients, message, product)
            refute cmd.success?
            assert_equal "Card Declined", cmd.errorDescription
        end
   end
   
   test "Invalid Recipient" do
        acct = accounts(:josh)
        recipients = ["(213) 456-789"]
        source = "pm_12345"
        message = "test"
        product = products(:beer)
        assert_no_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(acct, source, recipients, message, product)
            refute cmd.success?
            assert_equal "Invalid Phone Number", cmd.errorDescription
        end        
   end
   
   test "No Recipient" do
        acct = accounts(:josh)
        recipients = []
        source = "pm_12345"
        message = "test"
        product = products(:beer)
        assert_no_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(acct, source, recipients, message, product)
            refute cmd.success?
            assert_equal "No Recipients", cmd.errorDescription
        end        
   end
   
   test "Requires Action" do
        acct = accounts(:josh)
        recipients = [accounts(:pete).phone_number]
        source = MockStripePaymentIntent::REQUIRES_ACTION
        message = "test"
        product = products(:beer)
        assert_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(acct, source, recipients, message, product)
            assert cmd.success?
            order = cmd.result
            assert Order::PENDING_STATUS, order.status
        end 
   end
   
   test "No Product" do
        acct = accounts(:josh)
        recipients = [accounts(:pete).phone_number]
        source = "pm_12345"
        message = "test"
        product = nil
        assert_no_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(acct, source, recipients, message, product)
            refute cmd.success?
            assert_equal "No Product Specified", cmd.errorDescription
        end 
   end
   
end