class AccountRefactor < ActiveRecord::Migration[5.2]
  def change
    change_table :accounts do |t|
      t.string :type
      t.string :authentication_method
      t.string :password_digest
      t.string :reset_digest
      t.datetime :reset_sent_at
      t.belongs_to :user
    end
    
    reversible do |dir|
      dir.up do
        # Make all existing Accounts, MobilePhoneAccounts
        Account.update_all(type: MobilePhoneAccount.name, authentication_method: Account::AUTHX_OTP)

        # Create EmailAccounts for all existing Users
        User.all.each do |u| 
          name = "#{u.first_name} #{u.last_name}"
          if u.accounts.count == 0
            
            # Create a new EmailAccount
            a = EmailAccount.new(name: name, email: u.email, password_digest: u.password_digest, user: u)
            if a.save 
              puts "Created #{a.email}"
            else
              puts "Failed to create email account for user #{u.email}"
              puts a.errors.full_messages
            end
            
          end
        end
        
        # Update user association for all existing MobilePhoneAccounts
        MobilePhoneAccount.all.each do |a|
          username = if a.email
            a.email
          else
            a.phone_number
          end
          
          u = User.find_by(username: username)
          if u
            a.update(user: u)
          else  
            u = User.create(username: username, email: a.email, first_name: a.name)
            a.update(user: u)
          end
        end
        
        
      end
      
      dir.down do
        # Destroy EmailAccounts
        EmailAccount.all.destroy_all
        
      end
    end
  end
end
