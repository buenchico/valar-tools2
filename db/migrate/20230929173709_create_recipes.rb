class CreateRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :section
      t.string :description
      t.integer :difficulty
      t.integer :speed
      t.text :factors, array: true, default: []

      t.timestamps
    end
  end
end
