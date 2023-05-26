class CreateLocationsAndFamilies < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name_en
      t.string :name_es
      t.string :description
      t.float :x
      t.float :y
      t.string :region
      t.string :tags, array: true, default: []
      t.string :location_type
      t.boolean :visible

      t.timestamps
    end

    create_table :families do |t|
      t.string :name
      t.string :tags, array: true, default: []
      t.string :branch
      t.boolean :visible

      t.timestamps
    end

    add_reference :locations, :family
    add_reference :locations, :game
    add_reference :families, :game
  end
end
