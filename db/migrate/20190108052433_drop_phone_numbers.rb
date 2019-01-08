class DropPhoneNumbers < ActiveRecord::Migration[5.2]
  def change
    drop_table :phone_numbers
  end
end
