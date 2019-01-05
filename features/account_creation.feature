Feature: Account Creation
    New users identify themselves with a name, phone number, and one time password
    User can have multiple devices or phone numbers that are associate with 
    the same account.

  Background:
    Given A person named "Josh" with phone number "3109097243" and device "12345"
    Given A person named "Elo" with phone number "3108001646" and device "AC139"
    
  Scenario: Create a new account
    Given The person named "Elo" is not a current user
    When The person named "Elo" sends a request for a one time passcode
    Then A new account is created with identity name "Elo" and phone number "+13108001646"
    And A text message is sent to "+13108001646" with the one time passcode
    And The user named "Elo" does successfully authenticate with the one time passcode 
  
  Scenario: Create a new account but phone number exists
    Given The person named "Elo" is not a current user
    And The person named "Josh" is a current user
    And The user named "Josh" adds a phone number "3108001646"
    When The person named "Elo" sends a request for a one time passcode
    And A text message is sent to "+13108001646" with the one time passcode
    And The user named "Elo" does successfully authenticate with the one time passcode
    Then The user named "Elo" is associated with a phone number "3108001646"
    And The user named "Josh" is not associated with a phone number "3108001646"

  Scenario: Create a new account but phone number exists - FAILS
    Given The person named "Elo" is not a current user
    And The person named "Josh" is a current user
    And The user named "Josh" adds a phone number "3108001646"
    When The person named "Elo" sends a request for a one time passcode
    And The user named "Elo" does not successfully authenticate with the one time passcode
    Then The user named "Elo" is not associated with a phone number "3108001646"
    And The user named "Josh" is associated with a phone number "3108001646"
    
  Scenario: Reauthenticate 
    Given The person named "Josh" is a current user
    And The user named "Josh" is not authenticated
    When The user named "Josh" sends a request for a one time passcode
    Then A text message is sent to "+13109097243" with the one time passcode
    And The user named "Josh" does successfully authenticate with the one time passcode
    
  Scenario: Add a phone number to an account
    Given The person named "Josh" is a current user
    And The user named "Josh" is authenticated
    When The user named "Josh" adds a phone number "(205) 207-0297"
    Then The user named "Josh" is associated with a phone number "(310) 909-7243"
    And The user named "Josh" is associated with a phone number "(205) 207-0297"
  
  Scenario: Remove the last phone number from an account fails
    Given The person named "Josh" is a current user
    And The user named "Josh" is authenticated
    And The user named "Josh" has 1 associated phone number
    When The user named "Josh" tries to remove the phone number "(310) 909-7243"
    Then An error is returned with the message "The last phone number cannot be removed"
    And The user named "Josh" has 1 associated phone number
    
  Scenario: Remove a phone number from an account
    Given The person named "Josh" is a current user
    And The user named "Josh" is authenticated
    And The user named "Josh" adds a phone number "(205) 207-0297"
    When The user named "Josh" tries to remove the phone number "(310) 909-7243"
    Then The user named "Josh" is associated with a phone number "(205) 207-0297"
    And The user named "Josh" is not associated with a phone number "(310) 909-7243"
    