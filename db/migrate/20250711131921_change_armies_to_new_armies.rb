class ChangeArmiesToNewArmies < ActiveRecord::Migration[7.0]
  def change
    # Remove menN fields
    (1..9).each { |i| remove_column :armies, "men#{i}", :integer }

    # Remove attrN fields
    (0..9).each { |i| remove_column :armies, "attr#{i}", :integer }

    # Remove hp and hp_start — you were missing the table name!
    remove_column :armies, :hp, :integer
    remove_column :armies, :hp_start, :integer
    remove_column :armies, :army_type, :string

    add_column :armies, :xp, :integer, default: 100
    add_column :armies, :morale, :integer, default: 100

    create_table :units do |t|
      t.references :army, null: false, foreign_key: true
      t.string :unit_type
      t.integer :troops_start
      t.integer :count
      t.integer :modifier, default: 100

      t.timestamps
    end
  end
end
