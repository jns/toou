
class PlaceOrderCommandTest < ActiveSupport::TestCase
   
   def setup
   
   end
   
   test "call PlaceOrder" do
       @account = Account.find(1)
       @recipients = Account.all.map{|a| {"phoneNumber" => a.mobile}}
       @message = "Test Message"
       
       cmd = PlaceOrder.new(@account, @recipients, @message).call()
       assert cmd.success? 
       
       assert_equal(1, @account.orders.size)
       assert_equal(@recipients.size, @account.orders.first.passes.size)
       
   end
    
end