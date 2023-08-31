class AddLordToFamilies < ActiveRecord::Migration[7.0]
  def change
    add_reference :families, :lord, foreign_key: { to_table: :families }
  end
end
