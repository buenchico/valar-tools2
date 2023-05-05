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
       t.string :col0
       t.string :col1
       t.string :col2
       t.string :col3
       t.string :col4
       t.string :col5
       t.string :col6
       t.string :col7
       t.string :col8
       t.string :col9
       t.timestamps
     end

     create_table :armies_factions do |t|
       t.references :army, foreign_key: true
       t.references :faction, foreign_key: true
       t.timestamps
     end
   end
end
