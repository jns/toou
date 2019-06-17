class AlterCharges < ActiveRecord::Migration[5.2]
  def change
    change_table :charges do |t|
      t.integer :amount_cents
    end
    
    reversible do |dir|
      dir.up do
        Charge.all.each do |c|
          c.update(amount_cents: c.source_amount_cents)
        end
      end 
      dir.down do
        throw ActiveRecord::IrreversibleMigration
      end
    end
    
    change_table :charges do |t|
      t.remove :destination_amount_cents
      t.remove :source_amount_cents
      t.remove :merchant_id
    end 
    
  end
end
