class CompleteOrder

    prepend SimpleCommand
    
    cattr_accessor :payment_method_client, :payment_intent_client
    self.payment_intent_client = Stripe::PaymentIntent
    self.payment_method_client = Stripe::PaymentMethod
    
    def initialize(order)
       @order = order 
    end
    
    def call
        # save customer payment method
        intent = @@payment_intent_client.retrieve(@order.charge_stripe_id)
        customer = @order.account.stripe_customer_id
        begin 
            methods = Stripe::PaymentMethod.list(customer: @current_user.stripe_customer_id, type: "card")
            unless methods.find {|m| m.type == "card" && m.card.fingerprint == intent.payment_method.fingerprint}
                @@payment_method_client.attach(intent.payment_method, {customer: customer})
            end
        rescue Exception => e
            m = "Unable to save payment method for customer: #{e.message}" 
            Log.create(log_type: Log::ERROR, context: "ConfirmPaymenIntent", current_user: @order.account.id, message: m)
        end
        
        # Convert pending passes to actual passes
        PendingPass.where(order: @order).each do |pp|
            Log.create(log_type: Log::INFO, context: "ConfirmPaymentIntent", current_user: @order.account.id, message: "Converting pending pass to pass for order #{@order.id}")
            PendingPass.transaction do
                pp.createPass.id
                pp.destroy
            end
        end
        PassNotificationJob.perform_later(*@order.passes.collect{|pass| pass.id})
        return @order
    end
  
end