class ConfirmPaymentIntent

    prepend SimpleCommand
   
    cattr_accessor :payment_method_client, :payment_intent_client
    self.payment_intent_client = Stripe::PaymentIntent
    self.payment_method_client = Stripe::PaymentMethod
 
    def initialize(payment_intent_id) 
       @intent_id = payment_intent_id 
    end
    
    def call
        intent = @@payment_intent_client.confirm(@intent_id)
        order = Order.find_by(charge_stripe_id: @intent_id)
        if intent.status == "succeeded"
            # update order status
            order.update(status: Order::OK_STATUS)
        else
            # Log failure
            m = "PaymentIntent #{intent.id} confirmation returned with status #{intent.status}"
            Log.create(log_type: Log::ERROR, context: "ConfirmPayment", current_user: order.account.id, message: m)
        end
        
        return intent
    end
end