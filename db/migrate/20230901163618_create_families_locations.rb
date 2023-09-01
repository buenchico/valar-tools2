class CreateFamiliesLocations < ActiveRecord::Migration[7.0]
  def change
    add_reference :armies, :region, foreign_key: { to_table: :locations }
    add_reference :armies, :lord, foreign_key: { to_table: :families }
  end
end
