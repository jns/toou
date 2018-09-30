class AddColumnOrderToPasses < ActiveRecord::Migration
  def change
    add_reference :passes, :order, :index => true
  end
end
