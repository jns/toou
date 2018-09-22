class AddMessageToPass < ActiveRecord::Migration
  def change
    add_column :passes, :message, :string
  end
end
