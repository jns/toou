class AddStatusToOrder < ActiveRecord::Migration[5.2]
  def change
    change_table :orders do |t|
      t.string :status
    end
  end
end
