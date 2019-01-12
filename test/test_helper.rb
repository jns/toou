ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module TestEnvironment 
  # Load the database seed  
  Rails.application.load_seed

  # Test Environment Variables
  ENV["TWILIO_ACCOUNT_SID"] = "Test"
  ENV["TWILIO_AUTH_TOKEN"] = "Test"
  ENV["TWILIO_NUMBER"] = "Test"
  
  ENV["WEB_SERVICE_URL"]="https://toou-shaprioj.c9users.io"
  ENV["PKPASS_CERTIFICATE_PASSWORD"]="password123"  
  
  
  # Returns a valid auth token for an account
  def authenticate(account)
    phone_number = account.phone_number
    one_time_passcode = account.generate_otp
    command = AuthenticateUser.call(phone_number, one_time_passcode)
    if command.success?
      command.result
    else
      nil
    end
  end
  
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  
  include TestEnvironment
  
  
  MessageSender.client = FakeSMS
end
