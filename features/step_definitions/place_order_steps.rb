
When("The user named {string} sends a drink to {string}") do |name, recipient_phone_number|
    person = @people.find{|p| p.name == name}
    header "Authorization", "Bearer #{person.auth_token}"
    post "api/place_order", recipients: [recipient_phone_number], message: "ha ha"
    assert last_response.ok?
end

Then("A test message is sent to {string} with a redemption code") do |phone_number|
  last_message = FakeSMS.messages.last
  assert_equal phone_number, last_message.to
  puts last_message.body
end

Then("A notification is sent to the device {string}") do |string|
  pending # Write code here that turns the phrase above into concrete actions
end