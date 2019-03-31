class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.string :password_digest 
      t.datetime :password_validity
      t.string :device_id
      t.belongs_to :user

      t.timestamps
    end
  end
end
