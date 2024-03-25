class AddLineToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :line, :jsonb, default: []
  end
end
