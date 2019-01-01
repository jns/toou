class AlterAccountPhone < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :mobile, :string
  end
end
