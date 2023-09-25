class CreateMissions < ActiveRecord::Migration[7.0]
  def change
    create_table :missions do |t|
      t.string :name
      t.integer :discourse_id
      t.string :status
      t.string :notes
      t.date :started
      t.date :resolved
      t.references :game, null: false, foreign_key: true
      t.references :faction, null: false, foreign_key: true
      t.references :user, foreign_key: true # User is optional

      t.timestamps
    end
  end
end
