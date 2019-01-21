class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.string :pan
      t.string :token
      t.datetime :expiration
      t.string :cvc
      t.integer :spend_limit
      t.string :state
      t.bigint :pass_id
      
      t.timestamps
      
      t.index :pan
    end
    
  end
end
