ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Dir.glob("#{Rails.root}/test/mocks/*.rb").each do |rb_file|
  require rb_file
end

module TestEnvironment 
  # Load the database seed  
  Rails.application.load_seed

  # Test Environment Variables
  ENV["TWILIO_ACCOUNT_SID"] = "Test"
  ENV["TWILIO_AUTH_TOKEN"] = "Test"
  ENV["TWILIO_NUMBER"] = "Test"
  
  ENV["WEB_SERVICE_URL"]="https://toou-shaprioj.c9users.io"
  ENV["PKPASS_CERTIFICATE_PASSWORD"]="password123"  

  ENV["APN_SERVER"]="http://127.0.0.1:8181"
  
  # Returns a valid auth token for an account
  def forceAuthenticate(account)
    phone_number = account.phone_number
    one_time_passcode = account.generate_otp
    command = AuthenticateUser.call(phone_number, one_time_passcode)
    if command.success?
      command.result
    else
      puts "Error in test harness authenticating account #{account.to_json}"
      puts command.errors
      nil
    end
  end
  
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  
  include TestEnvironment
  
  MessageSender.client = FakeSMS
  ServerRequest.delegate = MockServer
end
