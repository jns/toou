require 'test_helper'

class PlaceOrderCommandTest < ActiveSupport::TestCase
   
    include ActionView::Helpers::NumberHelper
    
    def setup
        MockStripeCharge.charges.clear
        accounts(:josh).orders.clear   
        @promo = promotions(:generic)
    end
    
    test "Ordering a Product touches Stripe::Charge API" do
       from = accounts(:pete)
       to = [accounts(:josh).phone_number]
       assert_difference "MockStripeCharge.charges.count" do
            cmd = PlaceOrder.call(from, "payment source", to, "message", products(:beer))
           assert cmd.success?
           assert_equal products(:beer), cmd.result.passes.first.buyable
        end
    end
   
   test "Ordering a product creates an order" do
      from = accounts(:pete)
      to = [accounts(:beer_lover).phone_number]
      cmd = PlaceOrder.call(from, "pmt_source", to, "message", products(:beer))
      assert cmd.success?
      assert cmd.result.is_a? Order
      assert_not_nil cmd.result.charge_stripe_id
      assert_equal products(:beer).max_price_cents, cmd.result.commitment_amount_cents
      assert cmd.result.charge_amount_cents > cmd.result.commitment_amount_cents
   end
   
    test "Order a Promotion is possible" do
       from = accounts(:pete)
       to = [accounts(:josh).phone_number]
       cmd = PlaceOrder.call(from, "payment source", to, "message", promotions(:active))
       assert cmd.success?
       assert_equal promotions(:active), cmd.result.passes.first.buyable
    end
    
    test "Send an order to multiple recipients succeeds" do
        @account = accounts(:three)
    
        toaccounts = [accounts(:josh), accounts(:pete), accounts(:three)]
    
        # Build the recipient array
        @recipients = toaccounts.collect{|a| a.phone_number}
        @message = "Test Message"
        
           
       cmd = PlaceOrder.call(@account, "payment source", @recipients, @message, @promo)
       assert cmd.success? 
       order = cmd.result
        # This should be the only order
        assert_equal(order, @account.orders.last)
       # Confirm that each intended recipient received a pass from this order
       toaccounts.each{|a|
            assert a.passes.find{|p| p.order == order}
       }

        
    end
    
    test "sending an order to an empty number fails" do
        cmd = PlaceOrder.call accounts(:josh), "payment source", [nil], "message", @promo
        assert_equal false, cmd.success?
        assert_nil cmd.result
        assert_equal 0, accounts(:josh).orders.size
    end
    
   test "call PlaceOrder creates a new account" do 
      
      purchaser = accounts(:josh)
      
      # Generate a random 10 digit phone number and confirm it doesn't exist
      # newAcct = Array.new(10){ [*'0'..'9'].sample }.join
      newAcct = "1 888 888 8888"
      assert_nil( Account.search_by_phone_number(newAcct) )
      
      # Create parameters for api and invoke command
      recipients = [newAcct]
      
      cmd = PlaceOrder.call(purchaser, "payment source", recipients, "Message", @promo)
      assert cmd.success?
      
      # Assert that the phone number now exists and has an associated account
      assert_not_nil Account.search_by_phone_number(newAcct)
   end
   
   test "Order fails and no Stripe::Charge if recipient not provided" do
        cmd = PlaceOrder.call accounts(:josh), "payment source", [nil], "message", @promo
        refute cmd.success?
        assert_nil cmd.result
        assert_equal 0, accounts(:josh).orders.size
        assert MockStripeCharge.charges.empty?
    end
    
    test "Order fails, no charge, and no passes if payment source fails" do
       
       assert_no_difference ["Pass.count", "Order.count"] do 
           cmd = PlaceOrder.call accounts(:josh), MockStripeCharge::INVALID_PAYMENT, [accounts(:josh).phone_number], "message", products(:beer)
           refute cmd.success?
           assert_nil cmd.result
           assert MockStripeCharge.charges.empty?
       end
    end
    
    test "Test account cannot place orders to others" do
        cmd = PlaceOrder.call accounts(:test), "test_visa", [accounts(:josh).phone_number], "message", products(:beer)
        refute cmd.success?
    end
    
    test "Test account can place order to self" do
        cmd = PlaceOrder.call accounts(:test), "test_visa", [accounts(:test).phone_number], "message", products(:beer)
        assert cmd.success?
        assert_equal products(:beer), cmd.result.passes.first.buyable
    end
    
    test "Cannot place order without a buyable" do
       cmd = PlaceOrder.call accounts(:josh), "payment source", [accounts(:josh).phone_number], "message", nil
       refute cmd.success?
    end
    
end