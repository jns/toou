class SendRedemptionCode
  
  prepend SimpleCommand
  
  def initialize(pass)
    @pass = pass
  end
  
  # Generates a redemption code and sends via SMS to an account
  def call
  
      # generate a unique code
      code = generate_code
      while Pass.find_by(redemption_code: code) do
        code = generate_code
      end  
      
      @pass.redemption_code = code
      @pass.save
      
      recipient = @pass.account.phone_number
      sender = @pass.purchaser.phone_number
      message = "Hi.  You've got a drink waiting for you at TooU courtesy of #{sender}.  Download the app and used the redemption code #{code} to get your drink."
      
      if MessageSender.new.send_message(recipient, message)
        Log.create(log_type: Log::INFO, context: SendRedemptionCode.name, current_user: @pass.purchaser.id, message: "Redemption code sent from #{sender} to #{recipient}")
      else
        Log.create(log_type: Log::ERROR, context: SendRedemptionCode.name, current_user: @pass.purchaser.id, message: "Error sending redemption code from #{sender} to #{recipient}")
      end
  end
    
  private
  
  def generate_code
    (('A'..'Z').to_a + ('1'..'9').to_a).sample(6).join
  end
end
