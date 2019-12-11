class CaptureOrder
    
    prepend SimpleCommand
    
    cattr_accessor :transfer_client
    self.transfer_client = Stripe::Transfer
    
    def initialize(merchant, code)
       @merchant = merchant
       @code = code
    end
    
    def call
        
        
        begin
            throw "Invalid Code" unless (@code =~ /\d{4}/)
            @mpq = MerchantPassQueue.find_by(merchant: @merchant, code: @code.to_i) 
            @pass = @mpq.pass
        rescue
            Log.create(log_type: Log::ERROR, context: "CaptureOrder", current_user: @merchant.id, message: "Rejected Code #{@code} at Merchant #{@merchant.id}")
            errors.add(:unredeemable, "Invalid Code")
            return
        end
        
        product = @pass.buyable
        receiver = @pass.recipient
        order = @pass.order
        amount = @pass.value_cents
        account = @mpq.account
        
        if (receiver.is_a? Account and receiver.test_user?)
           errors.add(:unredeemable, "Test User cannot redeem passes")
           @mpq.destroy
           return
        end
        
        if receiver.is_a? Group and (account == nil or not @pass.recipient.accounts.member?(account))
            Log.create(log_type: Log::ERROR, context: "CaptureOrder", current_user: @merchant.id, message: "Group Pass #{@pass.id} not redeemable by Account" )
            errors.add(:unredeemable, "Pass not redeemable by user")
            @mpq.destroy
            return
        end
        
        unless @merchant.can_redeem?(@pass)
            Log.create(log_type: Log::ERROR, context: "CaptureOrder", current_user: @merchant.id, message: "Pass #{@pass.id} not redeemable by Merchant #{@merchant.id}")
            errors.add(:unredeemable, "#{@merchant.name} cannot redeem #{product.name}")
            @mpq.destroy
            return
        end
        
        if @pass.expired?
            Log.create(log_type: Log::ERROR, context: "CaptureOrder", current_user: @merchant.id, message: "Pass #{@pass.id} not redeemable due to expiration")
            errors.add(:unredeemable, "Pass is expired")
            @mpq.destroy
            return
        end
        
        if @pass.used?
            Log.create(log_type: Log::ERROR, context: "CaptureOrder", current_user: @merchant.id, message: "Pass #{@pass.id} not redeemable due prior use")
            errors.add(:unredeemable, "Pass was already used")
            @mpq.destroy
            return
        end
        
        begin
            
            transfer_id = if amount > 0 
                transfer(amount, @merchant, order).id
            else 
                @pass.serial_number
            end
            @pass.update(merchant: @merchant, 
                         transfer_stripe_id: transfer_id, 
                         transfer_amount_cents: amount, 
                         transfer_created_at: Time.new, 
                         redeemed_by: account)

            @mpq.destroy
            
            Log.create(log_type: Log::INFO, context: "CaptureOrder", current_user: receiver.id, message: "Captured order #{@pass.order.id}")
            
            PassRedeemedNotificationJob.perform_later(@pass.id)
            return @pass
                
        rescue Stripe::CardError => e
            # Since it's a decline, Stripe::CardError will be caught
            body = e.json_body
            err  = body[:error]
            errors.add(:stripe_card_error, err[:message])
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
        ensure
            errors.each do |err|
                Log.create(log_type: Log::ERROR, context: "CaptureOrder", current_user: receiver.id, message: err)
            end
        end
        
    end
   
   
    def transfer(amount, merchant, order)
        @@transfer_client.create(
            :amount => amount, # this number should be in cents
            :currency => "usd",
            :destination => merchant.stripe_id,
            :transfer_group => order.id,
            :metadata => {
                :order_id => order.id
            }
        )  
    end
end