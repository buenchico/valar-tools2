class CreateArmies < ActiveRecord::Migration[7.0]
  def change
     create_table :armies do |t|
       t.string :name
       t.string :status
       t.string :group
       t.string :position
       t.text :notes
       t.string :region
       t.string :lord
       t.boolean :visible
       t.text :tags, array: true, default: []
       t.integer :col0
       t.integer :col1
       t.integer :col2
       t.integer :col3
       t.integer :col4
       t.integer :col5
       t.integer :col6
       t.integer :col7
       t.integer :col8
       t.integer :col9
       t.timestamps
     end

     create_table :armies_factions do |t|
       t.references :army, foreign_key: true
       t.references :faction, foreign_key: true
       t.timestamps
     end
   end
end
