class AddOtpToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :one_time_password_hash, :string
    add_column :accounts, :one_time_password_validity, :datetime
  end
end
