class AlterTableOrders < ActiveRecord::Migration[5.2]
  def change
    change_table :orders do |t|
      t.belongs_to :charge
    end
  end
end
