class RemoveRegionAndLordFromArmies < ActiveRecord::Migration[7.0]
  def change
    remove_column :armies, :region, :string
    remove_column :armies, :lord, :string
  end
end
