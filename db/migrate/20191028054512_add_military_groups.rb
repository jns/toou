class AddMilitaryGroups < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      
      dir.up do
        Group.create(name: "Army", private: false)
        Group.create(name: "Navy", private: false)
        Group.create(name: "Air Force", private: false)
        Group.create(name: "Marines", private: false)
        Group.create(name: "Coast Guard", private: false)
      end
      
      dir.down do
        Group.find_by(name: "Army").destroy
        Group.find_by(name: "Navy").destroy
        Group.find_by(name: "Air Force").destroy
        Group.find_by(name: "Marines").destroy
        Group.find_by(name: "Coast Guard").destroy
      end
      
    end
  end
end
