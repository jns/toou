class PhoneNumber 

    attr_reader :country_code, :area_code, :phone_number

        
    # Attempts to locate a phone number by the given unsanitized string
    def initialize(phone_number_string)
        digits = PhoneNumber.remove_all_but_digits(phone_number_string)
        country = PhoneNumber.match_country(digits) || Country.find_by_abbreviation("US")
        @country_code, @area_code, @phone_number = PhoneNumber.split_phone_number(digits, country)
        raise "Invalid Phone Number" unless @area_code and @phone_number
    end
       
       
    # Removes all non-numeric characters from a string
    def PhoneNumber.remove_all_but_digits(number)
        number.gsub(/U[0-9a-f]{4}/, "")
              .gsub(/[^0-9]/, "")
    end 
    
    def PhoneNumber.match_country(digits)
        
        Country.all.each{|c|
            cc = c.country_code.to_s
            # If the first digits match the country code
            if (digits.index(cc) == 0)
                # Then confirm that the remaining digits are the correct length
                remainder = digits.slice(cc.size..-1)
                if c.phone_number_digit_range.include?(remainder.size)
                   return c 
                end
            end
        }
        
        return nil
    end
        
    # Matches the phone number for the given country
    # country code may be absent.
    # Returns a triple (cc, area_code, phone_number)
    def PhoneNumber.split_phone_number(digits, country)
        
        cc = country.country_code.to_s
        remainder = digits
        if (digits.index(cc) == 0)
            remainder = digits[cc.size..-1]
        end
        
        r = Regexp.new(country.area_code_regex) 
        
        if country.phone_number_digit_range.include?(remainder.size) && m = r.match(remainder)
            area_code = m[0]
            phone_number = remainder[area_code.size..-1]
            
            return cc, area_code, phone_number
        end
        
        return nil
    end
   
    def to_formatted_s
       "+" + country_code + area_code + phone_number
    end
    
    def to_s
       to_formatted_s 
    end
    
end
