require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  setup do
    
    # Seed test database with countries
    load "#{Rails.root}/db/seeds.rb"
    
    a = Account.find(1)
      a.phone_numbers << PhoneNumber.find_or_create_from_string("310-909-7243")
      a.save
      
    a = Account.find(2)
    a.phone_numbers << PhoneNumber.find_or_create_from_string("(504) 383-4228")
    a.save
  end
  
  test "phone number format" do
      assert_equal("+13109097243", Account.find(1).primary_phone_number.to_s)
      assert_equal("+15043834228", Account.find(2).primary_phone_number.to_s)
  end
  
  test "search by phoneNumber" do
    assert_not_nil(Account.search_by("phoneNumber" => "310 909 7243"))
    assert_not_nil(Account.search_by("phoneNumber" => "(504) 383-4228"))  
  end
  
  test "search or create by phone number" do

    number = "818 555-1212"
    
    # Remove account with phone number if it exists
    a = Account.search_by("phoneNumber" => number)
    a.destroy if a
  
    # Confirm that account does not exist
    assert_nil(Account.search_by("phoneNumber" => number))
    
    # Assert that account is created
    Account.search_or_create_by_recipient("phoneNumber" => number)
    assert_not_nil(Account.search_by("phoneNumber" => number))
  end
  
  
  
  test "search or create by email" do
      
  end
  
  test "search or create by account" do
    
  end
  
end
