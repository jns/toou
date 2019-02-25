class RenameSerialNumber < ActiveRecord::Migration[5.2]
  def change
    rename_column :passes, :serialNumber, :serial_number
  end
end
