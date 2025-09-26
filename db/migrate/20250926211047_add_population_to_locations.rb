class AddPopulationToLocations < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :population_start, :integer
    add_column :locations, :population, :integer
  end
end
