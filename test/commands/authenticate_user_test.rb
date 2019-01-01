
class AuthenticateUserTest < ActiveSupport::TestCase

    include ActionView::Helpers::NumberHelper
    
    def setup()
        # Seed test database with countries
        load "#{Rails.root}/db/seeds.rb"    
    end
    
    test "authenticate user succeeds" do
        acct = Account.find(1)
        acct.one_time_password_hash = "12345"
        acct.save
        
        cmd = AuthenticateUser.new(number_to_phone(acct.primary_phone_number), acct.one_time_password_hash).call
        
        assert cmd.success?
    end
   
end