class CreateStripeCustomerJob < ApplicationJob
  queue_as :default

  cattr_accessor :client
  self.client = Stripe::Customer

  def perform(user_id)
    u = User.find(user_id)
    unless u.stripe_customer_id
        begin
          customer = self.client.create(
            :metadata => {
              # Add our application's customer id for this Customer, so it'll be easier to look up
              :phone_number => u.phone_number,
            },
          )
          u.stripe_customer_id = customer.id
          u.save
        rescue Stripe::InvalidRequestError
          Log.create(log_type: Log::ERROR, context: "CreateStripeCustomerJob", current_user: user_id, message: "Stripe: Invalid Request Error")
        rescue Exception => e 
          Log.create(log_type: Log::ERROR, context: "CreateStripeCustomerJob", current_user: user_id, message: e.message)
        end
    end
  end
end
