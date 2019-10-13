class ChangeAccountToRecipient < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        add_reference :passes, :recipient, polymorphic: true
        add_reference :pending_passes, :recipient, polymorphic: true
        
        Pass.all.each do |p|
          a = Account.find(p.account_id)
          p.update(recipient: a)
        end
        
        remove_column :passes, :account_id
        remove_column :pending_passes, :account_id
      end 
      
      dir.down do
        add_reference :passes, :account
        add_reference :pending_passes, :account
        Pass.all.each do |p|
          if p.recipient.is_a? Account
            p.update(account_id: p.recipient.id)
          end
        end
        remove_column :passes, :recipient_id
        remove_column :passes, :recipient_type
        remove_column :pending_passes, :recipient_id
        remove_column :pending_passes, :recipient_type
      end 
    end
  end
end
