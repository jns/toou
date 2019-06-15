class CreateMerchantPassQueues < ActiveRecord::Migration[5.2]
  def change
    create_table :merchant_pass_queues do |t|
      t.belongs_to :merchant, null: false
      t.belongs_to :pass, null: false
      t.integer :code, null: false
      
      t.index [:merchant_id, :code]
      t.timestamps
    end
  end
end
