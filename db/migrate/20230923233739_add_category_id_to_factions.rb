class AddCategoryIdToFactions < ActiveRecord::Migration[7.0]
  def change
    add_column :factions, :category_id, :integer
  end
end
