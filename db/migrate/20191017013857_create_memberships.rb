class CreateMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :memberships do |t|

      t.timestamps
      t.belongs_to :account
      t.belongs_to :group
    end
  end
end
