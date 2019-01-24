require 'test_helper'

class PlaceOrderCommandTest < ActiveSupport::TestCase
   
    include ActionView::Helpers::NumberHelper
    
    def setup
        accounts(:josh).orders.clear   
        @promo = promotions(:generic)
    end
   
    test "Send an order to all existing account phone numbers succeeds" do
        @account = Account.find(3)
    
        toaccounts = Account.all
    
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

        # assert all passes have a valid payment method
        order.passes.each{|p| assert_not_nil p.card}
    
    end
    
    test "sending an order to an empty number fails" do
        cmd = PlaceOrder.call accounts(:josh), "payment source", [nil], "message", @promo
        assert_equal false, cmd.success?
        assert_nil cmd.result
        assert_equal 0, accounts(:josh).orders.size
    end
    
   test "call PlaceOrder creates a new account" do 
      
      purchaser = Account.find(1)
      
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
   
   
end