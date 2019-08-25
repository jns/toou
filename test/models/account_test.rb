require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  setup do
  end
  

  # Accounts can be searched by phone number even if the phone number is not formatted
  test "search by phoneNumber" do
    assert_not_nil(Account.search_by_phone_number("310 909 7243"))
    assert_not_nil(Account.search_by_phone_number("(504) 383-4228"))  
  end
  
  # Accounts are indexed by phone number, but phone numbers
  # must be formatted before account creation
  test "search or create by phone number" do

    number = "818 555-1212"
    
    # Remove account with phone number if it exists
    a = Account.search_by_phone_number(number)
    a.destroy if a
  
    # Assert that account is created
    acct = Account.find_or_create_by(phone_number:  number)
    assert_not_nil(Account.search_by_phone_number(number))
    assert_equal "+18185551212", acct.phone_number
  end
  
  # Accounts that have a device id can receive notifications
  test "can receive notifications" do
    
    assert accounts(:notifiable).can_receive_notifications?
    refute accounts(:not_notifiable).can_receive_notifications?
  end
  
  test "test authenticate test user" do
    acct = Account.search_by_phone_number("000-000-0000")
    assert acct.test_user?
    assert acct.authenticate("000000")
  end
  
  test "test missing fields" do
    assert_equal 0, accounts(:josh).missing_fields.count
    assert_equal 2, accounts(:test).missing_fields.count
    assert_equal 1, accounts(:pete).missing_fields.count
  end
  
end
