class CreateFactions < ActiveRecord::Migration[7.0]
  def change
    create_table :factions do |t|
      t.string :name
      t.string :long_name
      t.integer :discourse_id
      t.integer :reputation
      t.boolean :active

      t.timestamps
    end

    add_reference :users, :faction
  end
end
