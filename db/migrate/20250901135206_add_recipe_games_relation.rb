class AddRecipeGamesRelation < ActiveRecord::Migration[8.0]
  def change

    add_column :recipes, :visible, :boolean, default: true
  
    create_table :games_recipes, id: false do |t|
      t.references :game, null: false, foreign_key: true, index: true
      t.references :recipe, null: false, foreign_key: true, index: true
    end

    # Optional: Add a composite unique index to prevent duplicate pairs
    add_index :games_recipes, [:game_id, :recipe_id], unique: true
  end
end
