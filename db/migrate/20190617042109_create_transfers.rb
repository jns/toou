class CreateTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :transfers do |t|
      t.integer :amount_cents
      t.string :stripe_transfer_id
      t.belongs_to :merchant
      t.timestamps
    end
    
    change_table :passes do |t|
      t.belongs_to :transfer
    end
    
    reversible do |dir|
      dir.up do
        charges = Charge.where("stripe_id like 'tr%'")
        charges.each do |c|
          t = Transfer.create(stripe_transfer_id: c.stripe_id, 
                          amount_cents: c.destination_amount_cents,
                          merchant: c.merchant,
                          created_at: c.created_at)
          p = Pass.find_by(charge_id: c.id)
          p.update(transfer: t)
          c.destroy
        end
      end 
      
      dir.down do
        ActiveRecord::IrreversibleMigration 
      end 
    end

    change_table :passes do |t|
      t.remove :charge_id
    end
  end
end
