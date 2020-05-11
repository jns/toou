Feature: Place Order
  Users can place an order for other recipients
  Recipients receive notifications
  
  Background:
    Given A person named "Josh" with phone number "3109097243", email "josh@example.com", and device "12345"
    Given A person named "Elo" with phone number "3108001646", email "elo@example.com", and device "AC139"
    
  Scenario: Placing an order for a new user
    Given The person named "Josh" is a current user
    And The user named "Josh" is authenticated
    When The user named "Josh" sends a drink to "(310) 800-1646" using a valid payment
    And A text message is sent to "+13108001646" with a redemption code
    Then A notification is sent to the device "AC139"

  Scenario: Placing an order for an existing user
    Given The person named "Josh" is a current user
    And The user named "Josh" is authenticated
    And The person named "Elo" is a current user
    When The user named "Josh" sends a drink to "(310) 800-1646" using a valid payment
    Then A notification is sent to the device "AC139"
    
  Scenario: Capturing data for a first time customer
    Given The person named "Elo" is not a current user
    And The person named "Elo" has received a complimentary Toou
    When The user named "Elo" sends a drink to "(310) 909-7243" using a valid payment
    Then The account for "Elo" contains a name and email
    

  Scenario: The test user does not receive notifications
    Given The person named "Josh" is a current user
    And The user named "Josh" is authenticated
    When The user named "Josh" sends a drink to "(000) 000-0000" using a valid payment
    Then A text message is not sent to "+10000000000" with a redemption code
    