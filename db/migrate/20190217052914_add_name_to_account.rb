class AddNameToAccount < ActiveRecord::Migration[5.2]
  def change
    change_table :accounts do |t|
      t.string :name
    end
  end
end
