class AddPolygonToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :polygon, :jsonb, default: []
  end
end
