class Country < ActiveRecord::Base

    def phone_number_digit_range
       Range.new(self.phone_number_digits_min, self.phone_number_digits_max) 
    end
end
