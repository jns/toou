require 'test_helper'

class PhoneNumberTest  < ActiveSupport::TestCase
    
  def setup()
    @us = Country.find_by_abbreviation("US")
    @mx = Country.find_by_abbreviation("MX")
    @jp = Country.find_by_abbreviation("JP")
  end

  def teardown()
  end
  
  test "Countries loaded" do
    assert_not_nil @us
    assert_not_nil @mx
    assert_not_nil @jp
  end
  
  test "Countries match country code" do
    assert_equal @us, PhoneNumber.match_country("13109097243")
    assert_equal @jp, PhoneNumber.match_country("810645454545")
    assert_equal @mx, PhoneNumber.match_country("521234567890")
  end
  
  test "Can split phone number with country code by country" do
    country_code, area_code, number = PhoneNumber.split_phone_number("13109097243", @us)
    assert_equal "1", country_code
    assert_equal "310", area_code
    assert_equal "9097243", number
  end
  
  
  test "Can split phone number without country code by country" do
    country_code, area_code, number = PhoneNumber.split_phone_number("3109097243", @us)
    assert_equal "1", country_code
    assert_equal "310", area_code
    assert_equal "9097243", number
  end
  
  test "correctly identifies the test number" do 
    p = PhoneNumber.new("000-000-0000")
    assert_equal "1", p.country_code
    assert_equal "000", p.area_code
    assert_equal "0000000", p.phone_number
  end
  
  test "correctly parses area code and phone number without country code" do
    
    p = PhoneNumber.new("(310) 909-7243")
    assert_equal "310", p.area_code
    assert_equal "9097243", p.phone_number
    
    p = PhoneNumber.new("(310)-909-7243")
    assert_equal "310", p.area_code
    assert_equal "9097243", p.phone_number
    
    p = PhoneNumber.new("310-909-7243")
    assert_equal "310", p.area_code
    assert_equal "9097243", p.phone_number
    
    
    p = PhoneNumber.new("3109097243")
    assert_equal "310", p.area_code
    assert_equal "9097243", p.phone_number
    
  end
  
  test "correctly parses area code and phone number with a country code" do
    
    p = PhoneNumber.new("1 (310) 909-7243")
    assert_equal "1", p.country_code
    assert_equal "310", p.area_code
    assert_equal "9097243", p.phone_number
    
    p = PhoneNumber.new("81 (010)-909-7243")
    assert_equal "81", p.country_code
    assert_equal "010", p.area_code
    assert_equal "9097243", p.phone_number
    
    p = PhoneNumber.new("+52 310-909-7243")
    assert_equal "52", p.country_code
    assert_equal "", p.area_code
    assert_equal "3109097243", p.phone_number
    
    
    p = PhoneNumber.new("+81 0609097243")
    assert_equal "81", p.country_code
    assert_equal "060", p.area_code
    assert_equal "9097243", p.phone_number
    
    p = PhoneNumber.new("+13109097243")
    assert_equal "1", p.country_code
    assert_equal "310", p.area_code
    assert_equal "9097243", p.phone_number
    
  end
  
  test "country code defaults to U.S." do
  
    p = PhoneNumber.new("3109097243")
    assert_equal "1", p.country_code
    
    p = PhoneNumber.new("8187577604")
    assert_equal "1", p.country_code
    
    p = PhoneNumber.new("5258887604")
    assert_equal "1", p.country_code
    
  end

  test "fails for U.S. numbers shorter or longer than 10 digits" do
    
    assert_raise do
      PhoneNumber.new("1 (8188) 351-5155")
    end
    
    assert_raise do
      PhoneNumber.new("(520) 035-15155")
    end
    
    assert_raise do
      PhoneNumber.new("535-5155")
    end
  end
  
  test "phone number formatting" do
    p = PhoneNumber.new("(310) 909-7243")
    assert_equal "+13109097243", p.to_s
  end

end