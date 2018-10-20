ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


class FakeSMS
  Message = Struct.new(:from, :to, :body, :status)

  cattr_accessor :messages
  self.messages = []

  def initialize(_account_sid, _auth_token)
  end

  def messages
    self
  end

  def create(from:, to:, body:)
    m = Message.new(from: from, to: to, body: body, status: "queued")
    self.class.messages << messages
    return m
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  ENV["TWILIO_ACCOUNT_SID"] = "Test"
  ENV["TWILIO_AUTH_TOKEN"] = "Test"
  ENV["TWILIO_NUMBER"] = "Test"
  MessageSender.client = FakeSMS
end
