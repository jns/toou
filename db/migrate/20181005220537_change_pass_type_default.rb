class ChangePassTypeDefault < ActiveRecord::Migration[5.2]
  def change
    change_column(:passes, :passTypeIdentifier, :string, :null => false, :default => "pass.com.eloisaguanlao.testpass" )
  end
end
