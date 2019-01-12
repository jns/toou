class MessageSender

  cattr_accessor :client
  @@client = Twilio::REST::Client


  def initialize
    @client = self.class.client.new(
      ENV.fetch("TWILIO_ACCOUNT_SID"),
      ENV.fetch("TWILIO_AUTH_TOKEN"),
    )
    self
  end
  
  def send_code(phone_number, code)
    
    message = @client.messages.create(
      from:  ENV['TWILIO_NUMBER'],
      to:    phone_number,
      body:  code
    )

    message.status == 'queued'
  end
  
  def send_message(phone_number, message)
    message = @client.messages.create(
      from: ENV['TWILIO_NUMBER'],
      to: phone_number,
      body: message)  
      
      message.status == 'queued'
  end
  
end