class CaptureOrder
    
    prepend SimpleCommand
    
    cattr_accessor :charge_client
    self.charge_client = Stripe::Charge
    
    FEE_CENTS = 50
    
    def initialize(merchant, pass)
       @merchant = merchant
       @pass = pass
    end
    
    def call
        product = @pass.buyable
        amount = product.price(:cents, @merchant)
        sender = @pass.purchaser
        receiver = @pass.account
        
        unless @merchant.can_redeem?(@pass)
            errors.add(:unredeemable, "#{@merchant.name} cannot redeem #{product.name}")
            return
        end
        
        if @pass.expired?
            errors.add(:unredeemable, "Pass is expired")
            return
        end
        
        if @pass.used?
            errors.add(:unredeemable, "Pass was already used")
            return
        end
        
        begin
            dst_amount = amount
            src_amount = amount + FEE_CENTS
            response = charge(src_amount, dst_amount, sender, receiver, @merchant, @pass.order)
            c = Charge.create(account: @pass.account, 
                              merchant: @merchant, 
                              stripe_id: response.id, 
                              source_amount_cents: src_amount, 
                              destination_amount_cents: dst_amount)
            @pass.charge = c
            @pass.save
            Log.create(log_type: Log::INFO, context: "CaptureOrder", current_user: receiver.id, message: "Captured order #{@pass.order.id}")
        
        rescue Stripe::CardError => e
            # Since it's a decline, Stripe::CardError will be caught
            body = e.json_body
            err  = body[:error]
            errors.add(:stripe_card_error, err)
        rescue Stripe::RateLimitError => e
            # Too many requests made to the API too quickly
            errors.add(:stripe_rate_limit_error, e.message)
        rescue Stripe::InvalidRequestError => e
            # Invalid parameters were supplied to Stripe's API
            errors.add(:stripe_invalid_request_error, e.message)
        rescue Stripe::AuthenticationError => e
            # Authentication with Stripe's API failed
            # (maybe you changed API keys recently)
            errors.add(:stripe_authentication_error, e.message)
        rescue Stripe::APIConnectionError => e
            # Network communication with Stripe failed
            errors.add(:stripe_connect_error, e.message)
        rescue Stripe::StripeError => e
            # Display a very generic error to the user, and maybe send
            # yourself an email
            errors.add(:stripe_error, e.message)
        rescue => e
            # Something else happened, completely unrelated to Stripe
            errors.add(:unknown_error, e.message) 
        finally
            errors.each do |e|
                Log.create(log_type: Log::ERROR, context: "CaptureOrder", current_user: receiver.id, message: e)
            end
        end
        
    end
   
   
    def charge(src_amount, dst_amount, sender, receiver, merchant, order)
        @@charge_client.create(
            :amount => src_amount, # this number should be in cents
            :currency => "usd",
            :customer => sender.stripe_customer_id,
            :description => "TooU redeemed by #{receiver.phone_number}",
            :destination => {
                :amount => dst_amount,
                :account => merchant.stripe_id  
            },
            :metadata => {
                :order_id => order.id
            }
        )  
    end
end