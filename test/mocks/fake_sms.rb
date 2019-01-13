
class FakeSMS
  Message = Struct.new(:from, :to, :body, :status)

  cattr_accessor :messages
  self.messages = []

  def initialize(_account_sid, _auth_token)
  end

  # To mimic behavior of Twilio client, messages must return an object that implements "#create"
  def messages
    self
  end

  def create(from:, to:, body:)
    m = Message.new(from, to, body, "queued")
    self.class.messages << m
    return m
  end
end
