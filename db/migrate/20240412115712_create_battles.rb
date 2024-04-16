class CreateBattles < ActiveRecord::Migration[7.0]
  def change
    create_table :battles do |t|
      t.string :name
      t.datetime :date
      t.string :terrain
      t.string :status
      t.string :sideA
      t.string :sideB
      t.jsonb :skirmishA, default: { armies: nil, tokens: nil, strategy: nil, rolls: nil, results: nil}
      t.jsonb :skirmishB, default: { armies: nil, tokens: nil, strategy: nil, rolls: nil, results: nil}
      t.jsonb :engagementA, default: { armies: nil, tokens: nil, strategy: nil, rolls: nil, results: nil }
      t.jsonb :engagementB, default: { armies: nil, tokens: nil, strategy: nil, rolls: nil, results: nil }
      t.jsonb :combat_1A, default: { armies: nil, tokens: nil, strategy: nil, rolls: nil, results: nil }
      t.jsonb :combat_1B, default: { armies: nil, tokens: nil, strategy: nil, rolls: nil, results: nil }
      t.jsonb :combat_2A, default: { armies: nil, tokens: nil, strategy: nil, rolls: nil, results: nil }
      t.jsonb :combat_2B, default: { armies: nil, tokens: nil, strategy: nil, rolls: nil, results: nil }
      t.jsonb :combat_3A, default: { armies: nil, tokens: nil, strategy: nil, rolls: nil, results: nil }
      t.jsonb :combat_3B, default: { armies: nil, tokens: nil, strategy: nil, rolls: nil, results: nil }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
