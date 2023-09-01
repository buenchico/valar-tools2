class AddDescriptionToFamilies < ActiveRecord::Migration[7.0]
  def change
    add_column :families, :description, :string
  end
end
