# Call this command after an order has been initiated and the payment confirmed. 
# The order status must be OK in order to complete the order
# This command will save the payment method and convert the pending pass to a pass
class CompleteOrder

    prepend SimpleCommand
    
    cattr_accessor :payment_method_client, :payment_intent_client
    self.payment_intent_client = Stripe::PaymentIntent
    self.payment_method_client = Stripe::PaymentMethod
    
    def initialize(order)
       @order = order 
    end
    
    def call
        
        unless @order.status == Order::OK_STATUS
            message = "Cannot execute CompleteOrder on order #{@order.id}. Status must be OK"
            errors.add(:error, message)
            Log.create(log_type: Log::ERROR, context: "CompleteOrder", current_user: @order.account.id, message: message)
            return
        end
        
        if @order.charge_stripe_id
            # save customer payment method
            intent = @@payment_intent_client.retrieve(@order.charge_stripe_id)
            customer = @order.account.stripe_customer_id
            begin 
                pm_fingerprint = @@payment_method_client.retrieve(intent.payment_method).card.fingerprint
                methods = @@payment_method_client.list(customer: customer, type: "card")
                unless methods.find {|m| m.card.fingerprint == pm_fingerprint}
                    @@payment_method_client.attach(intent.payment_method, {customer: customer})
                end
            rescue Exception => e
                m = "Unable to save payment method for customer: #{e.message}" 
                Log.create(log_type: Log::ERROR, context: "CompleteOrder", current_user: @order.account.id, message: m)
            end
        end
        
        # Convert pending passes to actual passes
        PendingPass.where(order: @order).each do |pp|
            Log.create(log_type: Log::INFO, context: "CompleteOrder", current_user: @order.account.id, message: "Converting pending pass to pass for order #{@order.id}")
            PendingPass.transaction do
                pp.createPass.id
                pp.destroy
            end
        end
        PassNotificationJob.perform_later(*@order.passes.collect{|pass| pass.id})
        AccountMailer.with(order: @order).purchase_receipt.deliver_later
        return @order
    end
  
end