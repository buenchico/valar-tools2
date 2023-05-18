class CreateJoinTableGamesFactions < ActiveRecord::Migration[7.0]
  def change
    create_join_table :games, :factions do |t|
      t.index [:game_id, :faction_id]
      t.index [:faction_id, :game_id]
    end
  end
end
