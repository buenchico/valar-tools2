class CreateRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :section
      t.string :description
      t.integer :difficulty, default: 0
      t.integer :speed, default: 2
      t.jsonb :factors, default: {plus_simple_once: [], plus_simple_multiple: [], plus_double_once: [], plus_double_multiple: [], minus_simple_once: [], minus_simple_multiple: [], minus_double_once: [], minus_double_multiple: []}
      t.jsonb :results, default: {major: [], minor: [], improvement: []}

      t.timestamps
    end
  end
end
