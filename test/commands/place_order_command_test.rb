
class PlaceOrderCommandTest < ActiveSupport::TestCase
   
   include ActionView::Helpers::NumberHelper
   
   def setup
    # Seed test database with countries
    load "#{Rails.root}/db/seeds.rb"
   end
   
   test "Send an order to all existing account phone numbers succeeds" do
       @account = Account.find(3)

        toaccounts = Account.all

        # Build the recipient array
       @recipients = toaccounts.collect{|a| {"phoneNumber" => number_to_phone(a.primary_phone_number)}}
       @message = "Test Message"
       
       cmd = PlaceOrder.call(@account, @recipients, @message)
       assert cmd.success? 
       
       # This should be the only order
       assert_equal(1, @account.orders.size)
       order = @account.orders[0]
       
       # Confirm that each intended recipient received a pass from this order
       toaccounts.each{|a|
            assert a.passes.find{|p| p.order == order}
       }
       
   end
    
   test "call PlaceOrder creates a new account" do 
      
      purchaser = Account.find(1)
      
      # Generate a random 10 digit phone number and confirm it doesn't exist
      # newAcct = Array.new(10){ [*'0'..'9'].sample }.join
      newAcct = "18888888888"
      assert_nil( PhoneNumber.find_by_string(newAcct) )
      
      # Create parameters for api and invoke command
      recipients = [{"phoneNumber" => newAcct, "name" => "Someone"}]
      cmd = PlaceOrder.call(purchaser, recipients, "Message")
      assert cmd.success?
      
      # Assert that the phone number now exists and has an associated account
      p = PhoneNumber.find_by_string(newAcct)
      assert_not_nil p
      assert_not_nil p.account
   end
end