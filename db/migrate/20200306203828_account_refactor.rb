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
    
    change_table :users do |t|
      t.string :stripe_customer_id
    end
    
    reversible do |dir|
      dir.up do
        # Make all existing Accounts, MobilePhoneAccounts
        Account.update_all(type: MobilePhoneAccount.name, authentication_method: Account::AUTHX_OTP)

        # Create EmailAccounts for all existing Users with valid emails
        User.all.each do |u| 
          name = "#{u.first_name} #{u.last_name}"
          if u.accounts.count == 0
            
            # If no password and email matches google.com then create a GoogleAccount
            a = if u.password_digest == nil and u.email != nil
              GoogleAccount.create(name: name, email: u.email, user: u, authentication_method: Account::AUTHX_OAUTH)
            else
              # Create a new EmailAccount
              EmailAccount.new(name: name, email: u.email, password_digest: u.password_digest, user: u, authentication_method: Account::AUTHX_PASSWORD)
            end
            
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
          
          u = User.find_by(username: username) || User.create(username: username, email: a.email, first_name: a.name)
          
          a.update(user: u)
          u.update(stripe_customer_id: a.stripe_customer_id)
        end
        
        remove_column :users, :email
        remove_column :accounts, :stripe_customer_id
      end
      
      dir.down do
        
        # copy stripe_customer_id back to account
        add_column :accounts, :stripe_customer_id, :string
        Account.all.each do |a|
          a.update(stripe_customer_id: a.user.stripe_customer_id)
        end
        
        # Recreate user email accounts
        add_column :users, :email, :string
        EmailAccount.all.each do |a|
          a.user.email = a.email
          a.user.save
        end
        
        # Re-add tester email
        #User.find(username: "tester").update(email: "tester")
        
        # Destroy EmailAccounts
        EmailAccount.all.destroy_all
        
        # Destroy all other User accounts where email is null
        User.where(email: nil).destroy_all
        
        # Destroy Accounts without phone number
        Account.where(phone_number: nil).destroy_all
        
      end
    end
  end
end
