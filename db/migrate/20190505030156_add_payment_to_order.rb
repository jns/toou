class AddPaymentToOrder < ActiveRecord::Migration[5.2]
  def change
    change_table :passes do |t|
      t.string :payment_source
    end
  end
end
