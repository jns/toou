#  
#  Takes an account, and a list of recipients
#  generates an order with a set of passes
#  charges the users payment source and schedules notifications to recipients
class PlaceOrder

    prepend SimpleCommand
    
    cattr_accessor :charge_client, :customer_client
    self.charge_client = Stripe::Charge
    self.customer_client = Stripe::Customer
    
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
            ActiveRecord::Base.transaction do 
                
                throw "No Product Specified" unless @buyable
                
                Log.create(log_type: Log::INFO, context: PlaceOrder.name, current_user: @account.id, message: "Placing Order")
                
                @order = Order.create(account: @account)
                @recipients.each{ |r| 
                  throw "Recipient phone number cannot be empty" unless r
                  
                  # This will format the phone number 
                  pn = PhoneNumber.new(r).to_s
                  
                  # Only permit test users to place an order to themselve
                  if @account.test_user? and pn != @account.phone_number.to_s
                    throw "Test user can only place order for self"
                  end
                  
                  # generate the pass
                  create_pass(pn)
                }
                # Charge and notify if order and passes are successfully created
                # charge(@recipients.size,  @buyable.price(:cents))
            end
            
            @order.passes.each do |pass|
                PassNotificationJob.perform_later(pass.id)
            end
            
            return @order
        
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
        end
    end
    
    def charge(qty, unit_price)
        
        customer = @@customer_client.retrieve @account.stripe_customer_id
        unless customer.sources.member? @payment_source
            @payment_source = customer.sources.create(source: @payment_source)
        end
        
        Log.create(log_type: Log::INFO, context: "PlaceOrder#charge", current_user: @account.id, message: "Charging fee for order #{@order.id}")
        # Create the charge on Stripe's servers - this will charge the user's card
        @@charge_client.create(
            :amount => qty*100, # this number should be in cents
            :currency => "usd",
            :customer => @account.stripe_customer_id,
            :source => @payment_source,
            :description => "TooU Fee",
            :capture => true, 
            :metadata => {
                :order_id => @order.id
        })  
    end
    
    def create_pass(recipient_phone) 
        expiry = Date.today + 6.days
        acct = Account.find_or_create_by(phone_number: recipient_phone) 
        Log.create(log_type: Log::INFO, context: "PlaceOrder#create_pass", current_user: acct.id, message: "Creating pass for order #{@order.id}")
        Pass.create(message: @message, expiration: expiry, account: acct, order: @order, buyable: @buyable)
    end
    
end