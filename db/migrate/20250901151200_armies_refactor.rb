class ArmiesRefactor < ActiveRecord::Migration[8.0]
  def change
    def up
      drop_table :units, force: :cascade if table_exists?(:units)
      drop_table :armies, force: :cascade if table_exists?(:armies)
    end

    create_table :armies do |t|
      t.string :name, null: false
      t.string :position
      t.text :notes
      t.string :status
      t.string :group
      t.integer :xp, default: 100
      t.integer :morale, default: 100
      t.boolean :visible, default: true
      t.text :tags, default: [], array: true
      t.text :logs, default: [], array: true

      t.timestamps
    end

    create_table :units do |t|
      t.string :name, null: false
      t.string :unit_type
      t.integer :count, default: 0
      t.integer :count_start, default: 0
      t.integer :count_death, default: 0
      t.integer :strength_mod, default: 100
      t.integer :strength_indirect_mod, default: 100
      t.integer :hp_mod, default: 100
      t.boolean :visible, default: true
      t.text :tags, default: [], array: true
      t.text :logs, default: [], array: true

      t.references :army, foreign_key: true
      t.references :family, foreign_key: true
      t.references :location, foreign_key: true  # optional

      t.timestamps
    end

    create_table :factions_units, id: false do |t|
      t.references :unit, null: false, foreign_key: true
      t.references :faction, null: false, foreign_key: true
    end
    add_index :factions_units, [:unit_id, :faction_id], unique: true

    create_table :armies_factions, id: false do |t|
      t.references :army, null: false, foreign_key: true
      t.references :faction, null: false, foreign_key: true
    end
    add_index :armies_factions, [:army_id, :faction_id], unique: true
  end
end
