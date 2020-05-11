require 'securerandom'
require 'test_helper'

class AuthenticateUserTest < ActiveSupport::TestCase

    include ActionView::Helpers::NumberHelper
    
    def setup()
    end
    
    test "authenticate user succeeds" do
        acct = accounts(:josh)
        otp = acct.generate_otp
        acct.save
        
        cmd = AuthenticateUser.new(number_to_phone(acct.phone_number), otp).call
        assert cmd.success?
        
        token = cmd.result.token
        assert_not_nil token
        
        body = JsonWebToken.decode(token)
        assert_equal acct.id, body[:user_id]
    end
   
   test "authenticate user fails" do
      acct = accounts(:josh)
      otp = acct.generate_otp
      acct.save
      
      cmd = AuthenticateUser.call(number_to_phone(acct.phone_number), otp.succ)
      assert !cmd.success?
      assert_not_nil cmd.errors[:unauthorized]
   end
   
   test "authenticate Email User" do 
      acct = accounts(:joshEmail)
      password = SecureRandom.hex(10)
      acct.update(password: password)
      
      cmd = AuthenticateUser.call(acct.email, password, Account::AUTHX_PASSWORD)
      assert cmd.success?
        
        token = cmd.result.token
        assert_not_nil token
        
        body = JsonWebToken.decode(token)
        assert_equal acct.id, body[:user_id]
   end
   
   test "authenticate Email User Fails" do
      acct = accounts(:joshEmail)
      password = SecureRandom.hex(10)
      acct.update(password: password)
      
      cmd = AuthenticateUser.call(acct.email, SecureRandom.hex(10), Account::AUTHX_PASSWORD)
      assert !cmd.success?
      assert_not_nil cmd.errors[:unauthorized]
   end
   
   test "authenticate test user" do
        testnumber = "(000) 000-0000"
        testotp = "000000"
        cmd = AuthenticateUser.call(testnumber, testotp)
        assert cmd.success?
        assert_not_nil cmd.result.token
   end
   
   
end