class CreateBattles < ActiveRecord::Migration[7.0]
  def change
    create_table :battles do |t|
      t.string :name
      t.datetime :date
      t.string :terrain
      t.string :integer
      t.integer :status
      t.string :side_a
      t.string :side_b
      t.jsonb :skirmish, default: { armies: nil, missions: nil, rolls: nil, results: nil}
      t.jsonb :engagement, default: { armies: nil, missions: nil, rolls: nil, results: nil}
      t.jsonb :combat_1, default: { armies: nil, missions: nil, rolls: nil, results: nil}
      t.jsonb :combat_2, default: { armies: nil, missions: nil, rolls: nil, results: nil}
      t.jsonb :combat_3, default: { armies: nil, missions: nil, rolls: nil, results: nil}
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
