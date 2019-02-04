# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.create(name: "Admin")
Role.create(name: "Merchant")

Country.create(name: "United States of America", abbreviation: "US", country_code: 1, 
               phone_number_digits_min: 10, 
               phone_number_digits_max: 10,
               area_code_regex: "\\d\\d\\d")
               
Country.create(name: "Japan", abbreviation: "JP", country_code: 81, 
               phone_number_digits_min: 10, 
               phone_number_digits_max: 11,
               area_code_regex: "0\\d\\d0|0\\d0")
               
Country.create(name: "Mexico", abbreviation: "MX", country_code: 52, 
               phone_number_digits_min: 10, 
               phone_number_digits_max: 10,
               area_code_regex: "") # Mexico is mandating 10 digit numbers no area code should match
