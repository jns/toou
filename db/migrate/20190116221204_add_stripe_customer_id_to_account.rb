class AddStripeCustomerIdToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :stripe_customer_id, :string
  end
end
