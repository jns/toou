class MessageSender
  
  cattr_accessor :client
  self.client = Twilio::REST::Client

  def initialize
    @client = self.class.client.new(
      ENV.fetch("TWILIO_ACCOUNT_SID"),
      ENV.fetch("TWILIO_AUTH_TOKEN"),
    )
  end
  
  def send_code(phone_number, code)
    
    message = @client.messages.create(
      from:  ENV['TWILIO_NUMBER'],
      to:    phone_number,
      body:  code
    )

    message.status == 'queued'
  end
end