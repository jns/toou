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
  
  
  
  
end
