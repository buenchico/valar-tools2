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
      t.text :options, array: true, default: []
      t.boolean :master, default: false
      t.integer :sort, default: 0
      t.boolean :active, default: false

      t.timestamps
    end

    create_table :games_tools, id: false do |t|
      t.belongs_to :game
      t.belongs_to :tool
    end
  end
end
