class AddLoyaltyToFamilies < ActiveRecord::Migration[7.0]
  def change
    add_column :families, :loyalty_1, :integer
    add_column :families, :loyalty_2, :integer
    add_column :families, :loyalty_3, :integer
    add_column :families, :loyalty_4, :integer
    add_column :families, :loyalty_5, :integer
  end
end
