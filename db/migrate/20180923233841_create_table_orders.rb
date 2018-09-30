class CreateTableOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :account, :index => true
    end
  end
end
