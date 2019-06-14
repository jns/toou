class CreateRedemptionAuthToken
 
  prepend SimpleCommand
  
  def initialize(merchant)
    @merchant = merchant
  end

  def call
    JsonWebToken.encode(merchant_id: merchant.id, user_type: "Merchant", datetime: Time.new) 
  end

  private

  attr_accessor :merchant

end