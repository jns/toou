class RemoveColumnRecipientFromPasses < ActiveRecord::Migration
  def change
    remove_column :passes, :recipient_id
  end
end
