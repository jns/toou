

class Person
  attr_accessor :name, :phone_number, :device_id, :auth_token, :account
end


# Creates the account with provided name and phone number
# and caches the account for lookup in scenarios by name or phone number
Given("a user named {string} with phone number {string}") do |name, phone_number|
  a = Account.create(name: name)
  phone = PhoneNumber.find_or_create_from_string(phone_number)
  a.phone_numbers << phone
  a.save
  person = @people.find{|p| p.name == name and p.phone_number == phone_number}
  unless person
    person = Person.new()
    person.name = name
    person.phone_number = phone_number
    @people << person
  end
  person.account = a
end

# Ensures the account is exists and has a valid authentication token
Given("The user named {string} is authenticated") do |name|
  person = @people.find{|p| p.name == name}
  assert_not_nil person
  assert_not_nil person.account
  
  auth_token = authenticate(person.account)
  assert_not_nil auth_token
  person.auth_token = auth_token
end

When("The name {string}, phone number {string}, and device id {string} posts to the requestOneTimePasscode endpoint") do |name, phone_number, device_id|
  post "api/requestOneTimePasscode", name: name, phone_number: phone_number, device_id: device_id
  assert last_response.ok?
end

Then("A new account is created with identity name {string} and phone number {string}") do |name, phone_number|
  person = @people.find{|p| p.name == name and p.phone_number == phone_number}
  account = Account.find_by_mobile(phone_number)
  person.account = account if person
  assert_not_nil account
  assert_equal account.name, name
  assert_equal account.primary_phone_number, phone_number
end


When("The user named {string} adds a phone number {string}") do |name, phone_number|
  person = @people.find{|p| p.name == name}
  pn = PhoneNumber.find_or_create_from_string(phone_number)
  assert_not_nil person.account
  person.account.phone_numbers << pn
  person.account.save
end

Given("A person named {string} with phone number {string} and device {string}") do |name, phone_number, device_id|
  p = Person.new()
  p.name = name
  p.phone_number = phone_number
  p.device_id = device_id
  @people << p
end

Given("The person named {string} is not a current user") do |name|
  person = @people.find{|p| p.name == name}
  account = Account.find_by_mobile(person.phone_number)
  if account 
    account.numbers.each{|n| n.destroy}
    account.destroy
  end
end

Given("The person named {string} is a current user") do |name|
  person = @people.find{|p| p.name == name}
  unless person.account
    acct = Account.new(name: person.name)
    pn = PhoneNumber.find_or_create_from_string(person.phone_number)
    acct.phone_numbers << pn
    acct.save
    person.account = acct
  end
end

When("The person/user named {string} sends a request for a one time passcode") do |name|
  person = @people.find{|p| p.name == name}
  post "api/requestOneTimePasscode", name: person.name, phone_number: person.phone_number, device_id: person.device_id
  assert last_response.ok?
end

Then("A text message is sent to {string} with the one time passcode") do |phone_number|
  last_message = MessageSender.messages.last
  assert_equal phone_number, last_message.to
  assert last_message.body =~ /\d\d\d\d\d\d/
  @pass_code = last_message.body
end

Then("The user named {string} does successfully authenticate with the one time passcode") do |name|
  person = @people.find{|p| p.name == name}
  post "api/authenticate", pass_code: @pass_code, phone_number: person.phone_number, device_id: person.device_id
  assert last_response.ok?
  person.account = PhoneNumber.find_by_string(person.phone_number).account
end


When("The user named {string} does not successfully authenticate with the one time passcode") do |name|
  person = @people.find{|p| p.name == name}
  post "api/authenticate", pass_code: "000000", phone_number: person.phone_number, device_id: person.device_id
  assert !last_response.ok?
end

Then("The user named {string} is not associated with a phone number {string}") do |name, phone_number|
  pn = PhoneNumber.find_by_string(phone_number)
  assert_not_equal name, pn.account.name
end

Then("The user named {string} is associated with a phone number {string}") do |name, phone_number|
  person = @people.find{|p| p.name == name}
  pn = PhoneNumber.find_by_string(phone_number)
  assert_not_nil person.account
  assert_equal person.account.id, pn.account.id
end

Given("The user named {string} is not authenticated") do |name|
  person = @people.find{|p| p.name == name}
  assert_nil person.auth_token
end

Given("The user named {string} has {int} associated phone number(s)") do |name, quantity|
  person = @people.find{|p| p.name == name}
  assert_not_nil person.account
  assert_equal quantity, person.account.phone_numbers.size
end

When("The user named {string} tries to remove the phone number {string}") do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("An error is returned with the message {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

