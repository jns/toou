
# Ensures the account is exists and has a valid authentication token
Given("The user/person named {string} is authenticated") do |name|
  person = @people.find{|p| p.name == name}
  assert_not_nil person
  assert_not_nil person.account
  
  auth_token = forceAuthenticate(person.account)
  assert_not_nil auth_token
  person.auth_token = auth_token
end


# Assert that an account exists for the person
Then("An account exists for the person named {string} and phone number {string}") do |name, phone_number|
  person = @people.find{|p| p.name == name and p.phone_number == phone_number}
  account = Account.search_by_phone_number(phone_number)
  person.account = account if person
  assert_not_nil account
  assert_equal account.phone_number, phone_number
end


# Caches the named person in a local instance variable
Given("A person named {string} with phone number {string}, email {string}, and device {string}") do |name, phone_number, email, device_id|
  p = Person.new()
  p.name = name
  p.email = email
  p.phone_number = phone_number
  p.device_id = device_id
  @people << p
end

# Destroys the account associated with the given person
Given("The person named {string} is not a current user") do |name|
  person = @people.find{|p| p.name == name}
  account = Account.search_by_phone_number(person.phone_number)
  if account 
    account.destroy
  end
  person.account = nil
end

# Creates an account for the named person
Given("The person named {string} is a current user") do |name|
  person = @people.find{|p| p.name == name}
  unless person.account
    pn = PhoneNumber.new(person.phone_number).to_s
    acct = Account.create(phone_number: pn, device_id: person.device_id)
    acct.save
    person.account = acct
  end
end

# Posts to the api endpoint for requesting a one time passcode and asserts a successful response
When("The person/user named {string} sends a request for a one time passcode") do |name|
  person = @people.find{|p| p.name == name}
  post "api/requestOneTimePasscode", phone_number: person.phone_number, device_id: person.device_id
  assert last_response.ok?
end

# Asserts that an SMS was added to the the mock SMS service 
# and caches the body of the message to an instance variable
Then("A text message is sent to {string} with the one time passcode") do |phone_number|
  last_message = FakeSMS.messages.last
  assert_equal phone_number, last_message.to
  assert last_message.body =~ /\d\d\d\d\d\d/
  @pass_code = last_message.body
end

# Posts the cached one time passcode for the named user to the authentication endpoint
# and asserts a successful response.  Adds the authentication token to the cached person
Then("The user named {string} does successfully authenticate with the one time passcode") do |name|
  person = @people.find{|p| p.name == name}
  post "api/authenticate", pass_code: @pass_code, phone_number: person.phone_number, device_id: person.device_id
  assert last_response.ok?
  json = JSON.parse(last_response.body)
  person.auth_token = json["auth_token"]
  assert_not_nil person.auth_token
end


# Asserts that the 
Given("The user named {string} is not authenticated") do |name|
  person = @people.find{|p| p.name == name}
  assert_nil person.auth_token
end

