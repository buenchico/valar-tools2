class AddTierToFamilies < ActiveRecord::Migration[7.0]
  def change
    add_column :families, :tier, :string
  end
end
