class AlterAccountPhone < ActiveRecord::Migration[5.2]
  def change
    rename_column :accounts, :mobile, :phone_number
    remove_column :accounts, :name, :string
    add_index :accounts, :phone_number
  end
end
