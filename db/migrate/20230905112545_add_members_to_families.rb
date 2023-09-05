class AddMembersToFamilies < ActiveRecord::Migration[7.0]
  def change
    add_column :families, :members, :string
  end
end
