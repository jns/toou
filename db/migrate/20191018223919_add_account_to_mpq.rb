class AddAccountToMpq < ActiveRecord::Migration[5.2]
  def change
    change_table :merchant_pass_queues do |t|
      t.belongs_to :account
    end
  end
end
