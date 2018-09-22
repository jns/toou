class AddAccountColumnToPass < ActiveRecord::Migration
  def change
    add_reference :passes, :account, index: true
  end
end
