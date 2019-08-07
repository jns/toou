class AddValueToPass < ActiveRecord::Migration[5.2]
  def change
    change_table :passes do |t|
      t.integer :value_cents
    end
    
    Pass.all.each do |pass|
      order = pass.order
      value = order.commitment_amount_cents ? order.commitment_amount_cents / order.passes.count : 0
      pass.update(value_cents: value)
    end
  end
end
