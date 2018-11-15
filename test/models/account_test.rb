require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  setup do
    a = Account.find(1)
      a.mobile = "310-909-7243"
      a.save
      
    a = Account.find(2)
    a.mobile = "(504) 383-4228"
    a.save
  end
  
  test "phone number format" do
      assert_equal("3109097243", Account.find(1).mobile)
      assert_equal("5043834228", Account.find(2).mobile)
  end
  
  test "search by phoneNumber" do
    assert_not_nil(Account.search_by("phoneNumber" => "310 909 7243"))
    assert_not_nil(Account.search_by("phoneNumber" => "(504) 383-4228"))  
  end
  
end
