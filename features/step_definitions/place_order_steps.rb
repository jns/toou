
When("The user named {string} sends a drink to {string}") do |name, recipient_phone_number|
    person = @people.find{|p| p.name == name}
    header "Authorization", "Bearer #{person.auth_token}"
    post "api/place_order", recipients: [recipient_phone_number], message: "ha ha"
    assert last_response.ok?
end

Then("A text message is sent to {string} with a redemption code") do |phone_number|
  last_message = FakeSMS.messages.last
  assert_equal phone_number, last_message.to
end

Then("A notification is sent to the device {string}") do |device_id|
  notification = MockApnoticConnector.notifications.last
  assert_not_nil notification
  assert_equal device_id, notification[:notification].token
end