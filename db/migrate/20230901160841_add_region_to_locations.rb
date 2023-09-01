class AddRegionToLocations < ActiveRecord::Migration[7.0]
  def change
    remove_column :locations, :region, :string
    add_reference :locations, :region, foreign_key: { to_table: :locations }
  end
end
