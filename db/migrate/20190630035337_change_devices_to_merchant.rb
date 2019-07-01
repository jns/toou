class ChangeDevicesToMerchant < ActiveRecord::Migration[5.2]
  def change
    change_table :devices do |t|
      t.belongs_to :merchant
    end
    
    reversible do |dir|
      dir.up do
        remove_column :devices, :user_id
        Device.destroy_all()
      end 
      
      dir.down do
        add_column :devices, :user_id, :bigint
        add_index :devices, :user_id
      end 
    end
  end
end
