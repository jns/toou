Given("I am on the home page") do
  visit "/"
end

Then("I should see {string}") do |string|
  assert page.has_content?(string)
end