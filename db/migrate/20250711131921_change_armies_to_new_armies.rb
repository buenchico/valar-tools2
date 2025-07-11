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

    create_table :units do |t|
      t.references :army, null: false, foreign_key: true
      t.string :unit_type
      t.integer :men_start
      t.integer :men
      t.float :unit_strength
      t.float :armour

      t.timestamps
    end
  end
end
