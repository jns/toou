

When("The user named {string} sends a drink to {string} using a valid payment") do |name, recipient_phone_number|
    person = @people.find{|p| p.name == name}
    puts @beer
    perform_enqueued_jobs do 
      post "api/order", purchaser: {name: person.name, email: person.email, phone: person.phone_number}, recipients: [recipient_phone_number], message: "ha ha", payment_source: "valid_payment_token", product: {id: @beer.id, type: @beer.class.name} 
      puts last_response.body
      assert last_response.ok?
    end
end

Then("A text message is sent to {string} with a redemption code") do |phone_number|
  last_message = FakeSMS.messages.last
  assert_equal phone_number, last_message.to
end

Then("A text message is not sent to {string} with a redemption code") do |phone_number|
  last_message = FakeSMS.messages.last
  if last_message
    assert_difference phone_number, last_message.to
  end
end

Then("A notification is sent to the device {string}") do |device_id|
  notification = MockApnoticConnector.notifications.last
  assert_not_nil notification
  assert_equal device_id, notification[:notification].token
end

Given("The person named {string} has received a complimentary Toou") do |name|
  receiver = @people.find{|p| p.name === name}
  cmd = PlaceOrder.call(@admin_account ,"visa_tok", [receiver.phone_number], "complimentary toou", @beer) 
  puts cmd.errors
  assert cmd.success?
end

Then("The account for {string} contains a name and email") do |name|
  person = @people.find{|p| p.name === name}
  account = Account.search_by_phone_number(person.phone_number)
  assert_equal person.name, account.name
  assert_equal person.email, account.email
end
