class RemoveGameIdFromFactions < ActiveRecord::Migration[7.0]
  def change
    remove_reference :factions, :game
  end
end
