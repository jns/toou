class PaymentsController  < ApiBaseController

  def ephemeral_keys
    begin
      key = Stripe::EphemeralKey.create(
        {customer: @current_user.stripe_customer_id},
        {stripe_version: params["api_version"]}
      )
    rescue Stripe::StripeError => e
      Log.create(log_type: Log::ERROR, context: "PaymentsController#ephemeral_keys", current_user: @current_user.id, message: e.message)
      render json: {error: "Error getting ephemeral key"}, status: 402
    end
  
    render json: key.to_json, status: :ok
    
  end

  def charge
      amount, source = params.require(['amount', 'source'])
      customer = params.permit('customer_id') || @current_user.stripe_customer_id
    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      @charge = Stripe::Charge.create(
        :amount => amount, # this number should be in cents
        :currency => "usd",
        :customer => customer,
        :source => source,
        :description => "Example Charge",
        :capture => true)
    rescue Stripe::StripeError => e
      m = "Error creating charge: #{e.message}"
      Log.create(log_type: Log::ERROR, context: "PaymentsController#charge", current_user: @current_user.id, message: m)
      render json: {"error": m}, status: 402
    end
  
    Log.create(log_type: Log::INFO, context: "PaymentsController#charge", current_user: @current_user.id, message: "Charge Successful")
    render json: {"charge_identifier": @charge.id}.to_json, status: 200
  end
end
