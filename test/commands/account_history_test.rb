
# Test account history
class AuthenticateUserTest < ActiveSupport::TestCase

    def setup()
       @acct = Account.find(2) 
    end

    # Account 1 has 2 orders and 1 pass
    test "Account History is accurate" do
        cmd = AccountHistory.call(@acct)
        assert cmd.success?
        assert_equal 2, cmd.result.select{|i| i.activity_type == HistoryItem::SEND_ACTIVITY_TYPE }.size
        assert_equal 1, cmd.result.select{|i| i.activity_type == HistoryItem::RECEIVE_ACTIVITY_TYPE }.size
    end
    
    test "Account History is sorted" do
       cmd = AccountHistory.call(@acct)
       history = cmd.result
       assert history[0].date < history[1].date
       assert history[1].date < history[2].date
    end

end