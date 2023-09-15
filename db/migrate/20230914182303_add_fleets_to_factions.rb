class AddFleetsToFactions < ActiveRecord::Migration[7.0]
  def change
    add_column :factions, :fleets, :jsonb
    add_column :factions, :fleets_notes, :string
  end
end
