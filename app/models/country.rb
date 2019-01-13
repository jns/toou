class Country < ActiveRecord::Base

    validates_uniqueness_of :country_code

    def phone_number_digit_range
       Range.new(self.phone_number_digits_min, self.phone_number_digits_max) 
    end
end
