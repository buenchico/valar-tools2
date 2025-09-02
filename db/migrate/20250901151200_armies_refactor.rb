class ArmiesRefactor < ActiveRecord::Migration[8.0]
  def change
    drop_table :armies, force: :cascade
    drop_table :units, force: :cascade

    create_table :armies do |t|
      t.string :name, null: false
      t.string :position
      t.text :notes
      t.integer "xp", default: 100
      t.integer "morale", default: 100
      t.text "logs", default: [], array: true
      t.text :tags, default: [], array: true

      t.timestamps
    end

    create_table :units do |t|
      t.string :name, null: false
      t.string :unit_type
      t.integer :count
      t.integer :count_start
      t.integer :count_death
      t.integer :strength
      t.integer :strength_indirect
      t.integer :hp
      t.text :tags, default: [], array: true

      t.references :army, foreign_key: true
      t.references :family, foreign_key: true
      t.references :location, foreign_key: true  # optional

      t.timestamps
    end
  end
end
