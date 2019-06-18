#  
#  Takes an account, and a list of recipients
#  generates an order with a set of passes
#  charges the users payment source and schedules notifications to recipients
class PlaceOrder

    prepend SimpleCommand
    
    FEE = 125
    
    cattr_accessor :charge_client, :customer_client, :source_client
    self.charge_client = Stripe::Charge
    self.customer_client = Stripe::Customer
    self.source_client = Stripe::Source
    
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

            throw "No Product Specified" unless @buyable
            throw "No Recipients" unless @recipients.count > 0
            
            Log.create(log_type: Log::INFO, context: PlaceOrder.name, current_user: @account.id, message: "Placing Order")
            
            # Create an order 
            order = Order.create(account: @account)
            
            @recipients.each{ |r| 
              throw "Recipient phone number cannot be empty" unless r
              
              # This will format the phone number 
              pn = PhoneNumber.new(r).to_s
              
              # Only permit test users to place an order to themselve
              if @account.test_user? and pn != @account.phone_number.to_s
                throw "Test user can only place order for self"
              end
              
              # generate the pass
              create_pass(pn, @message, @buyable, order)
            }
            
            
            # Amount to keep in reserve to payout merchants
            commitment_amount_cents = @buyable.price(:cents)*order.passes.count
            # Amount charged to the customer
            charge_amount_cents = commitment_amount_cents + FEE*order.passes.count
            
            # Create the charge on Stripe's servers - this will charge the user's card
            c =  @@charge_client.create(
                :amount => charge_amount_cents, # this number should be in cents
                :currency => "usd",
                :source => @payment_source,
                :transfer_group => order.id,
                :description => "TooU Purchase",
                :capture => true, 
                :metadata => {
                    :order_id => order.id,
                    :customer_id => @account.id,
                    :commitment_amount => commitment_amount_cents
                })
            Log.create(log_type: Log::INFO, context: "PlaceOrder#charge", current_user: @account.id, message: "Charged for order #{order.id}")
            
            
            order.update(charge_amount_cents: charge_amount_cents,
                        commitment_amount_cents: commitment_amount_cents,
                        charge_stripe_id: c.id)
            
            order.passes.each do |pass|
                PassNotificationJob.perform_later(pass.id)
            end
            
            return order
        
        rescue Stripe::CardError => e
            # Since it's a decline, Stripe::CardError will be caught
            body = e.json_body
            err  = body[:error]
            m = "Stripe Card Error: #{err}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:stripe_card_error, m)
        rescue Stripe::RateLimitError => e
            # Too many requests made to the API too quickly
            m = "Stripe Rate Limit Error: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:stripe_rate_limit_error, e.message)
        rescue Stripe::InvalidRequestError => e
            # Invalid parameters were supplied to Stripe's API
            m = "Stripe Invalid Request Error: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:stripe_invalid_request_error, m)
        rescue Stripe::AuthenticationError => e
            # Authentication with Stripe's API failed
            # (maybe you changed API keys recently)
            m = "Stripe Authentication Error: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:stripe_authentication_error, m)
        rescue Stripe::APIConnectionError => e
            # Network communication with Stripe failed
            m = "Stripe API Connection Error: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:stripe_connect_error, m)
        rescue Stripe::StripeError => e
            m = "Error creating charge: #{e.message}"
            Log.create(log_type: Log::ERROR, context: "PlaceOrderCommand#charge", current_user: @account.id, message: m)
            errors.add(:stripe_error, m)
        rescue Exception => e
            message = "Error creating order: #{e.message}"
            Log.create(log_type: Log::ERROR, context: PlaceOrder.name, current_user: @account.id, message: message)
            errors.add(:internal_server_error, message)
        ensure
            if errors.count > 0 and @order
               @order.update(status: Order::FAILED_STATUS) 
               @order.passes.each{|p| p.destroy}
            end
        end
    end
    
    def create_pass(recipient_phone, message, buyable, order) 
        expiry = Date.today + 180.days
        acct = Account.find_or_create_by(phone_number: recipient_phone) 
        Log.create(log_type: Log::INFO, context: "PlaceOrder#create_pass", current_user: acct.id, message: "Creating pass for order #{order.id}")
        Pass.create(message: message, expiration: expiry, account: acct, order: order, buyable: buyable)
    end
    
end