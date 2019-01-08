

class Person
  attr_accessor :name, :phone_number, :device_id, :auth_token, :account
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


Then("A new account is created for the person named {string} and phone number {string}") do |name, phone_number|
  person = @people.find{|p| p.name == name and p.phone_number == phone_number}
  account = Account.search_by_phone_number(phone_number)
  person.account = account if person
  assert_not_nil account
  assert_equal account.phone_number, phone_number
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
  account = Account.search_by_phone_number(person.phone_number)
  if account 
    account.destroy
  end
end

Given("The person named {string} is a current user") do |name|
  person = @people.find{|p| p.name == name}
  unless person.account
    pn = PhoneNumber.new(person.phone_number).to_s
    acct = Account.create(phone_number: pn)
    acct.save
    person.account = acct
  end
end

When("The person/user named {string} sends a request for a one time passcode") do |name|
  person = @people.find{|p| p.name == name}
  post "api/requestOneTimePasscode", phone_number: person.phone_number, device_id: person.device_id
  assert last_response.ok?
end

Then("A text message is sent to {string} with the one time passcode") do |phone_number|
  last_message = FakeSMS.messages.last
  assert_equal phone_number, last_message.to
  assert last_message.body =~ /\d\d\d\d\d\d/
  @pass_code = last_message.body
end

Then("The user named {string} does successfully authenticate with the one time passcode") do |name|
  person = @people.find{|p| p.name == name}
  post "api/authenticate", pass_code: @pass_code, phone_number: person.phone_number, device_id: person.device_id
  assert last_response.ok?
  person.account = Account.search_by_phone_number(person.phone_number)
end




Given("The user named {string} is not authenticated") do |name|
  person = @people.find{|p| p.name == name}
  assert_nil person.auth_token
end

