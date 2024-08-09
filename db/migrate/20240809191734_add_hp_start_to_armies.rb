class AddHpStartToArmies < ActiveRecord::Migration[7.0]
  def change
    add_column :armies, :hp_start, :integer, default: 100
  end
end
