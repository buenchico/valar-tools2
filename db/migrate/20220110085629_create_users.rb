class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :player
      t.string :faction
      t.integer :discourse_id
      t.string :avatar_url
      t.string :auth_token

      t.timestamps
    end
  end
end
