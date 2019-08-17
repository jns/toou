class CreatePendingPasses < ActiveRecord::Migration[5.2]
  def change
    create_table :pending_passes do |t|
      t.integer "account_id"
      t.string "message"
      t.integer "order_id"
      t.integer "buyable_id"
      t.string "buyable_type"
      t.integer "value_cents"
      t.index ["account_id"], name: "index_pending_passes_on_account_id"
      t.index ["order_id"], name: "index_pending_passes_on_order_id"
    
      t.timestamps
    end
  end
end
