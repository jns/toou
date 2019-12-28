class AddColumnsToUser < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :picture_url
      t.string :locale
    end
  end
end
