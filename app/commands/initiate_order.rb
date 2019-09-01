#  
#  Takes an account, and a list of recipients
#  generates an order with a set of passes
#  charges the users payment source and schedules notifications to recipients
class InitiateOrder

    prepend SimpleCommand
    
    FEE = 125
    
    cattr_accessor :payment_intent_client
    self.payment_intent_client = Stripe::PaymentIntent

    # Account is the account placing the order
    # payment_source is a stripe payment source token
    # Recipients are specified as an array of phone numbers to receive passes
    # payment_source is a stripe payment source token
    # message is a message to deliver with the pass
    # buyable is a product or promotion
    def initialize(account, payment_source, recipients, message, buyable)
        @account = account
        @payment_source = payment_source
        @recipients = recipients
        @message = message
        @buyable = buyable
    end
    
    def call

        begin
            raise "Invalid Acount" unless @account.is_a? Account
            raise "No Product Specified" unless @buyable
            raise "No Recipients" unless @recipients.count > 0

            Order.transaction do # Wrap everything in a transaction
                # Create an order 
                @order = Order.create(account: @account)
                
                
                Log.create(log_type: Log::INFO, context: InitiateOrder.name, current_user: @account.id, message: "Initiating Order")

                
                @recipients.each{ |r| 
                  throw "Recipient phone number cannot be empty" unless r
                  
                  # This will format the phone number 
                  pn = PhoneNumber.new(r).to_s
                  
                  # Only permit test users to place an order to themselve
                  if @account.test_user? and pn != @account.phone_number.to_s
                    throw "Test user can only place order for self"
                  end
                  
                  # generate the pass
                  create_pass(pn, @message, @buyable, @order)
                }
                
                
                # Amount to keep in reserve to payout merchants
                commitment_amount_cents = @buyable.price(:cents)*@recipients.count
                # Amount charged to the customer
                charge_amount_cents = commitment_amount_cents + FEE*@recipients.count
                
                # Create a payment intent. 
                intent = @@payment_intent_client.create(
                    :amount => charge_amount_cents,
                    :currency => "usd", 
                    :payment_method => @payment_source,
                    :transfer_group => @order.id,
                    :customer => @account.stripe_customer_id,
                    :description => "TooU Purchase", 
                    :confirmation_method => "manual", 
                    :confirm => true,
                    :setup_future_usage => 'on_session',
                    :metadata => {
                        :order_id => @order.id, 
                        :customer_id => @account.id,
                        :commitment_amount => commitment_amount_cents
                    })
                
                @order.update(charge_amount_cents: charge_amount_cents,
                             commitment_amount_cents: commitment_amount_cents,
                             charge_stripe_id: intent.id)
                
                if intent.status == 'succeeded'
                    @order.update(status: Order::OK_STATUS)
                    CompleteOrder.call(@order)
                elsif intent.status == 'requires_confirmation' 
                    # Manual confirmation method means that we have a second chance to confirm how.
                    intent = ConfirmPaymentIntent.call(intent.id).result
                    CompleteOrder.call(@order) if intent.status == 'succeeded'
                elsif (intent.status == 'requires_action' && intent.next_action.type == 'use_stripe_sdk')
                    @order.update(status: Order::PENDING_STATUS)
                else
                    # Cancel payment intent here
                    @order.update(status: Order::FAILED_STATUS)
                end

                @order.payment_intent = intent
            end # End of transaction

            # @order.passes.each do |pass|
            #     PassNotificationJob.perform_later(pass.id)
            # end
            
            return @order
        
        rescue Stripe::CardError => e
            # Since it's a decline, Stripe::CardError will be caught
            m = "Stripe Card Error: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:message, e.message)
        rescue Stripe::RateLimitError => e
            # Too many requests made to the API too quickly
            m = "Stripe Rate Limit Error: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:message, e.message)
        rescue Stripe::InvalidRequestError => e
            # Invalid parameters were supplied to Stripe's API
            m = "Stripe Invalid Request Error: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:message, m)
        rescue Stripe::AuthenticationError => e
            # Authentication with Stripe's API failed
            # (maybe you changed API keys recently)
            m = "Stripe Authentication Error: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:message, m)
        rescue Stripe::APIConnectionError => e
            # Network communication with Stripe failed
            m = "Stripe API Connection Error: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:message, m)
        rescue Stripe::StripeError => e
            m = "Error creating charge: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:message, m)
        rescue Exception => e
            message = e.message
            Log.create(log_type: Log::ERROR, context: PlaceOrder.name, current_user: @account.id, message: message)
            errors.add(:message, message)
        end
    end
    
    def create_pass(recipient_phone, message, buyable, order) 
        expiry = Date.today + 180.days
        acct = Account.find_or_create_by(phone_number: recipient_phone) 
        Log.create(log_type: Log::INFO, context: "InitiateOrder#create_pass", current_user: acct.id, message: "Creating pending pass for order #{order.id}")
        PendingPass.create(message: message, account: acct, order: order, buyable: buyable, value_cents: buyable.price(:cents))
    end
    
    def errorDescription
       errors.collect{|e, m| return m.join(",")}.join(",")
    end
    
end