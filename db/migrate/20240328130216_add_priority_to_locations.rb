class AddPriorityToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :priority, :integer, default: 0, limit: 2
  end
end
