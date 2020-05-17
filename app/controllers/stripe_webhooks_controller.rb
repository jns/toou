class StripeWebhooksController < ApiBaseController
    
    # GET enrolls a new merchant with stripe
    def enroll
        authorize Merchant
        state, code = params.require([:state, :code])
        
        if code === "TEST_OK"
            @merchant = Merchant.new(name: "Test")
            render status: :ok
            return
        end
        
        if code === "TEST_ERROR"
           @error = "Testing error"
           render status: :ok
           return
        end
        
        begin
            @merchant = Merchant.find(state)
            cmd = EnrollStripeConnectedAccount.call(@merchant, code)
            unless cmd.success?
                @error = cmd.errors[:enrollment_error]
            end
        rescue ActiveRecord::RecordNotFound
            render status: :bad_request
        end
    end
    
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
