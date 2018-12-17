
class PlaceOrderCommandTest < ActiveSupport::TestCase
   
   include ActionView::Helpers::NumberHelper
   
   def setup
   
   end
   
   test "call PlaceOrder" do
       @account = Account.find(3)
       @recipients = Account.all.map{|a| {"phoneNumber" => number_to_phone(a.mobile)}}
       @message = "Test Message"
       
       cmd = PlaceOrder.call(@account, @recipients, @message)
       assert cmd.success? 
       
       assert_equal(1, @account.orders.size)
       assert_equal(@recipients.size, @account.orders.first.passes.size)
   end
    
   test "call PlaceOrder new account" do 
      @account = Account.find(1)
      newAcct = Array.new(10){ [*'0'..'9'].sample }.join
      assert_nil( Account.find_by(:mobile => newAcct) )
      @recipients = [{"phoneNumber" => newAcct}]
      cmd = PlaceOrder.call(@account, @recipients, "Message")
      assert cmd.success?
   end
end