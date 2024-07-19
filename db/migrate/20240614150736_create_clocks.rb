class CreateClocks < ActiveRecord::Migration[7.0]
  def change
    create_table :clocks do |t|
      t.string :name
      t.string :style, default: "clock"
      t.integer :status, default: 0
      t.integer :size
      t.integer :outcome, default: 0
      t.string :description
      t.string :logs
      t.boolean :visible, default: true

      t.timestamps
    end

    add_reference :clocks, :family
  end
end
