
class AuthenticateUserTest < ActiveSupport::TestCase

    include ActionView::Helpers::NumberHelper
    
    test "authenticate user succeeds" do
        acct = Account.find(1)
        acct.one_time_password_hash = "12345"
        acct.save
        
        cmd = AuthenticateUser.new(number_to_phone(acct.mobile), acct.one_time_password_hash).call
        
        assert cmd.success?
    end
   
end