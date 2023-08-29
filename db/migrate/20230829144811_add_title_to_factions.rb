class AddTitleToFactions < ActiveRecord::Migration[7.0]
  def change
    add_column :factions, :title, :string
  end
end
