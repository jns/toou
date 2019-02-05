

When("The user named {string} sends a drink to {string} using a valid payment") do |name, recipient_phone_number|
    person = @people.find{|p| p.name == name}
    header "Authorization", "Bearer #{person.auth_token}"
    perform_enqueued_jobs do 
      post "api/place_order", recipients: [recipient_phone_number], message: "ha ha", payment_source: "valid_payment_token", product_id: @beer.id, product_type: @beer.class.name 
      assert last_response.ok?
    end
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
