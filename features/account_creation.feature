Feature: Account Creation
    New users identify themselves with a name, phone number, and one time password
    
  Background:
    Given A person named "Josh" with phone number "(310) 909-7243" and device ""
    Given A person named "Elo" with phone number "(310) 800-1646" and device "AC139"
    
  Scenario: Create a new account
    Given The person named "Elo" is not a current user
    When The person named "Elo" sends a request for a one time passcode
    Then An account exists for the person named "Elo" and phone number "+13108001646"
    And A text message is sent to "+13108001646" with the one time passcode
    And The user named "Elo" does successfully authenticate with the one time passcode 
  
  Scenario: Reauthenticate 
    Given The person named "Josh" is a current user
    And The user named "Josh" is not authenticated
    When The user named "Josh" sends a request for a one time passcode
    Then A text message is sent to "+13109097243" with the one time passcode
    And The user named "Josh" does successfully authenticate with the one time passcode
  