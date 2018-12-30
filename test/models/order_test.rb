require 'test_helper'

class OrderTest < ActiveSupport::TestCase

    def setup
      @acct1 = Account.find(1)
    end
    
    test "Order has timestamp at creation" do
      o = Order.new
      o.account = @acct1
      o.save
      
      assert_not_nil o.created_at
    end

end
