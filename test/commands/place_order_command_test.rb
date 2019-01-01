
class PlaceOrderCommandTest < ActiveSupport::TestCase
   
   include ActionView::Helpers::NumberHelper
   
   def setup
    # Seed test database with countries
    load "#{Rails.root}/db/seeds.rb"
   end
   
   test "call PlaceOrder" do
       @account = Account.find(3)
       @recipients = Account.all.map{|a| {"phoneNumber" => number_to_phone(a.primary_phone_number)}}
       @message = "Test Message"
       
       cmd = PlaceOrder.call(@account, @recipients, @message)
       assert cmd.success? 
       
       assert_equal(1, @account.orders.size)
       assert_equal(@recipients.size, @account.orders.first.passes.size)
       @account.orders.each do |o| 
          assert_not_nil o.created_at
       end
   end
    
   test "call PlaceOrder new account" do 
      @account = Account.find(1)
      newAcct = Array.new(10){ [*'0'..'9'].sample }.join
      assert_nil( PhoneNumber.find_by_string(newAcct) )
      @recipients = [{"phoneNumber" => newAcct}]
      cmd = PlaceOrder.call(@account, @recipients, "Message")
      assert cmd.success?
   end
end