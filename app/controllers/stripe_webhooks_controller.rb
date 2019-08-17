class StripeWebhooksController < ApiBaseController
    
    def stripe_event
        payload = request.body.read
        event = nil
    
        begin
            event = Stripe::Event.construct_from(
                JSON.parse(payload, symbolize_names: true)
            )
        rescue JSON::ParserError => e
            # Invalid payload
            head :bad_request
            return
        end
    
        # Handle the event
        case event.type
        when 'payment_intent.succeeded'
          payment_intent = event.data.object # contains a Stripe::PaymentIntent
            Log.create(log_type: Log::INFO, context: "StripeWebhook#stripe_event", message: "payment_intent.succeeded #{payment_intent}")
        else
          # Unexpected event type
            head :bad_request
          return
        end
    
        head :ok
    end
end
