class CreateRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :section
      t.string :description
      t.integer :difficulty, default: 0
      t.integer :speed, default: 2
      t.jsonb :factors, default: {double_plus: [], plus: [], double_minus: [], minus: []}
      t.jsonb :results, default: {major: [], minor: [], improvement: []}

      t.timestamps
    end
  end
end
