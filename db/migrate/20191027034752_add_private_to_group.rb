class AddPrivateToGroup < ActiveRecord::Migration[5.2]
  def change
    change_table :groups do |t|
      t.boolean :private, default: true
    end
  end
end
