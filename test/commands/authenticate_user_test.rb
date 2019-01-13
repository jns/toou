
class AuthenticateUserTest < ActiveSupport::TestCase

    include ActionView::Helpers::NumberHelper
    
    def setup()
    end
    
    test "authenticate user succeeds" do
        acct = Account.find(1)
        acct.one_time_password_hash = "12345"
        acct.save
        
        cmd = AuthenticateUser.new(number_to_phone(acct.phone_number), acct.one_time_password_hash).call
        assert cmd.success?
        
        token = cmd.result
        assert_not_nil token
        
        body = JsonWebToken.decode(token)
        assert_equal acct.id, body[:user_id]
    end
   
   test "authenticate user fails" do
      acct = accounts(:josh)
      acct.one_time_password_hash = "12345"
      acct.save
      
      cmd = AuthenticateUser.call(number_to_phone(acct.phone_number), acct.one_time_password_hash.succ)
      assert !cmd.success?
      assert_not_nil cmd.errors[:unauthorized]
   end
end