class RemoveCharges < ActiveRecord::Migration[5.2]
  def change
    # Modifies Passes to support accounting when pass is redeemed
    change_table :passes do |t|
      t.belongs_to :merchant
      t.string :transfer_stripe_id
      t.integer :transfer_amount_cents
      t.datetime :transfer_created_at
    end
    
    # Modifies Orders to track order payment
    change_table :orders do |t|
      t.string :charge_stripe_id
      t.integer :charge_amount_cents
      t.integer :commitment_amount_cents
    end
    
    # Moves charges into orders or passes
    reversible do |dir|
      dir.up do
        Pass.joins(:charge).each do |pass|
          charge = pass.charge
          pass.merchant = charge.merchant
          pass.transfer_stripe_id = charge.stripe_id
          pass.trasnfer_amount_cents = charge.destination_amount_cents
          pass.transfer_created_at = charge.created_at
          pass.save
          
          order = pass.order
          order.charge_stripe_id = charge.stripe_id
          order.charge_amount_cents = charge.source_amount_cents
          order.commitment_amount_cents = charge.destination_amount_cents
          order.save
        end
      end
      
      dir.down do
        Pass.where("transfer_stripe_id is not null").each do |pass|
          order = pass.order
          Charge.create(account_id: order.account_id,
                        merchant_id: pass.merchant_id,
                        source_amount_cents: order.charge_amount_cents,
                        destination_amount_cents: pass.trasnfer_amount_cents,
                        stripe_id: pass.transfer_stripe_id,
                        created_at: pass.transfer_created_at)
        end
      end
      
    end
    
    change_table :passes do |t|
      t.remove :charge
      t.remove :redemption_code
    end
    
    drop_table :charges do |t|
      t.bigint "account_id"
      t.bigint "merchant_id"    
      t.integer "source_amount_cents"
      t.integer "destination_amount_cents"
      t.string "stripe_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["account_id"], name: "index_charges_on_account_id"
      t.index ["merchant_id"], name: "index_charges_on_merchant_id"
    end
  end
end
