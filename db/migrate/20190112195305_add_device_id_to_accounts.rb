class AddDeviceIdToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :device_id, :string
  end
end
