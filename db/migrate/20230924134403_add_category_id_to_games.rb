class AddCategoryIdToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :category_id, :integer
  end
end
