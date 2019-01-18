class CreateStripeCustomerJob < ApplicationJob
  queue_as :default

  cattr_accessor :client
  self.client = Stripe::Customer

  def perform(account_id)
    a = Account.find(account_id)
    unless a.stripe_customer_id
        begin
          customer = self.client.create(
            :metadata => {
              # Add our application's customer id for this Customer, so it'll be easier to look up
              :phone_number => a.phone_number,
            },
          )
          a.stripe_customer_id = customer.id
          a.save
        rescue Stripe::InvalidRequestError
          Log.create(log_type: Log::ERROR, context: "CreateStripeCustomerJob", current_user: account_id, message: "Stripe: Invalid Request Error")
        rescue Exception => e 
          Log.create(log_type: Log::ERROR, context: "CreateStripeCustomerJob", current_user: account_id, message: e.message)
        end
    end
  end
end
