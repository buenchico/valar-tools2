class CreateGamesAndTools < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.string :name
      t.string :title
      t.string :prefix
      t.string :icon_url
      t.boolean :active, default: false

      t.timestamps
    end

    create_table :tools do |t|
      t.string :name
      t.string :title
      t.string :short_title
      t.string :icon_url
      t.text :options_info, default: ''
      t.string :role, default: 'player'
      t.integer :sort, default: 0
      t.boolean :active, default: false

      t.timestamps
    end

    create_table :game_tools do |t|
      t.belongs_to :game
      t.belongs_to :tool

      t.boolean :active, default: false
      t.jsonb :options

      t.timestamps
    end

    create_table :factions_games do |t|
      t.references :faction, foreign_key: true
      t.references :game, foreign_key: true
      t.timestamps
    end
  end
end
