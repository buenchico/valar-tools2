class AddFactionToFamilies < ActiveRecord::Migration[7.0]
  def change
    add_reference :families, :faction
  end
end
