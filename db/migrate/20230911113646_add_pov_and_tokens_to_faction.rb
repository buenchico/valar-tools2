class AddPovAndTokensToFaction < ActiveRecord::Migration[7.0]
  def change
    add_column :factions, :pov, :string
    add_column :factions, :tokens, :string
  end
end
