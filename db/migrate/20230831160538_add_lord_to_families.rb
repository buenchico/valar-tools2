class AddLordToFamilies < ActiveRecord::Migration[7.0]
  def change
    add_column :families, :lord, :string
  end
end
