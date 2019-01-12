Feature: Place Order
  Users can place an order for other recipients
  Recipients receive notifications
  
  Background:
    Given A person named "Josh" with phone number "3109097243" and device "12345"
    Given A person named "Elo" with phone number "3108001646" and device "AC139"
    
  Scenario: Placing an order for a new user
    Given The person named "Josh" is a current user
    And The user named "Josh" is authenticated
    When The user named "Josh" sends a drink to "(310) 800-1646"
    Then A text message is sent to "+13108001646" with a redemption code
    
  Scenario: Placing an order for an existing user
    Given The person named "Josh" is a current user
    And The user named "Josh" is authenticated
    And The person named "Elo" is a current user
    When The user named "Josh" sends a drink to "(310) 800-1646"
    Then A notification is sent to the device "AC139"