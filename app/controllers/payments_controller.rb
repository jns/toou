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

end
