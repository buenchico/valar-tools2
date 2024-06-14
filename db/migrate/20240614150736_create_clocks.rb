class CreateClocks < ActiveRecord::Migration[7.0]
  def change
    create_table :clocks do |t|
      t.string :name
      t.string :logs
      t.integer :status
      t.integer :size
      t.string :description

      t.timestamps
    end

    add_reference :clocks, :family, foreign_key: true
  end
end
