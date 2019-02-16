class AddCharges < ActiveRecord::Migration[5.2]
  def change
      change_table :passes do |t|
        t.remove :proof_of_purchase
        t.belongs_to :charge
      end
      
      create_table :charges do |t|
        t.belongs_to :account
        t.belongs_to :merchant
        t.integer :source_amount_cents
        t.integer :destination_amount_cents
        t.string :stripe_id
      end
  end
end
