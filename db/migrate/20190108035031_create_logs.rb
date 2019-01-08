class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.string :log_type
      t.string :message
      t.string :context
      t.bigint :current_user

      t.timestamps
    end
  end
end
