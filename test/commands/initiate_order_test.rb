require 'test_helper'

class InitiateOrderTest < ActiveSupport::TestCase
   
    def setup
        MockStripePaymentIntent.intents.clear
        users(:josh).orders.clear   
        @promo = promotions(:generic)
    end
    
    test "Zero Cost Product" do
        user = users(:josh)
        recipients = [accounts(:pete).phone_number]
        source = ""
        message = "test"
        product = products(:zero_product)

        assert_no_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(user, source, recipients, message, product, product.fee(:cents))
           assert cmd.success?
           order = cmd.result
           assert_equal 1, order.passes.count
           pass = order.passes.first
           assert_equal Order::OK_STATUS, order.status
           assert_equal 1, order.passes.count
           
           assert_equal users(:pete), pass.recipient
           assert_equal product, pass.buyable
           assert_equal 0, pass.value_cents
           assert_equal message, pass.message
           assert_equal 0, order.commitment_amount_cents
           assert_equal 0, order.charge_amount_cents
        end
    end 
    
    test "Order placed for unknown user" do
       user = users(:josh)
       newAcct = "1 888 888 8889"
      assert_nil( MobilePhoneAccount.search_by_phone_number(newAcct) )
        recipients = [newAcct]
        source = "pm_12345"
        message  = "test"
        product = products(:cupcake)
        assert_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(user, source, recipients, message, product, product.fee(:cents))
            assert cmd.success?
        end
      assert_not_nil MobilePhoneAccount.search_by_phone_number(newAcct)
        
    end
    
   test "Order Succeeds" do
       user = users(:josh)
       recipients = [accounts(:pete).phone_number]
       source = "pm_12345"
       message = "test"
       product = products(:cupcake)
       
       assert_difference 'MockStripePaymentIntent.intents.count' do
           cmd = InitiateOrder.call(user, source, recipients, message, product, product.fee(:cents))
           assert cmd.success?
           order = cmd.result
           intent = MockStripePaymentIntent.retrieve(order.charge_stripe_id)
           assert_equal Order::OK_STATUS, order.status
           assert_equal intent, order.payment_intent
           assert_equal 1, order.passes.count
           pass = order.passes.first
           assert_equal users(:pete), pass.recipient
           assert_equal product, pass.buyable
           assert_equal product.max_price_cents, pass.value_cents
           assert_equal message, pass.message
           assert_equal MockStripePaymentIntent.intents.last.id, intent.id
           assert_equal order.commitment_amount_cents, product.max_price_cents
           assert_equal product.max_price_cents+product.fee, order.charge_amount_cents
       end
   end
   
   test "Card Declined" do
        user = users(:josh)
        recipients = [accounts(:pete).phone_number]
        source = MockStripePaymentIntent::INVALID_PAYMENT
        message = "test"
        product = products(:beer)
        
        assert_no_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(user, source, recipients, message, product, product.fee(:cents))
            refute cmd.success?
            assert_equal "Card Declined", cmd.errorDescription
        end
   end
   
   test "Recipient is group" do
        user = users(:josh)
        recipient = [{"group" => groups(:army).id}]
        source = "pm_12345"
        message = "Group Purchase Test"
        product = products(:beer)
        assert_difference 'MockStripePaymentIntent.intents.count' do 
            cmd = InitiateOrder.call(user, source, recipient, message, product, product.fee(:cents))
            assert cmd.success?
        end 
   end 
   
   test "Invalid Recipient" do
        user = users(:josh)
        recipients = ["(213) 456-789"]
        source = "pm_12345"
        message = "test"
        product = products(:beer)
        assert_no_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(user, source, recipients, message, product, product.fee(:cents))
            refute cmd.success?
            assert_equal "Invalid Phone Number", cmd.errorDescription
        end        
   end
   
   test "No Recipient" do
        user = users(:josh)
        recipients = []
        source = "pm_12345"
        message = "test"
        product = products(:beer)
        assert_no_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(user, source, recipients, message, product, product.fee(:cents))
            refute cmd.success?
            assert_equal "No Recipients", cmd.errorDescription
        end        
   end
   
   test "Requires Action" do
        user = users(:josh)
        recipients = [accounts(:pete).phone_number]
        source = MockStripePaymentIntent::REQUIRES_ACTION
        message = "test"
        product = products(:beer)
        assert_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(user, source, recipients, message, product, product.fee(:cents))
            assert cmd.success?
            order = cmd.result
            assert Order::PENDING_STATUS, order.status
        end 
   end
   
   test "No Product" do
        user = users(:josh)
        recipients = [accounts(:pete).phone_number]
        source = "pm_12345"
        message = "test"
        product = nil
        assert_no_difference 'MockStripePaymentIntent.intents.count' do
            cmd = InitiateOrder.call(user, source, recipients, message, product, nil)
            refute cmd.success?
            assert_equal "No Product Specified", cmd.errorDescription
        end 
   end
   
end