class AddResetToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :reset_digest
      t.datetime :reset_sent_at
    end
  end
end
