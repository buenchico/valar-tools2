class AddOpenToClocks < ActiveRecord::Migration[7.0]
  def change
    add_column :clocks, :open, :boolean, default: true
  end
end
