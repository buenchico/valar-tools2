class AddSidesToClocks < ActiveRecord::Migration[7.0]
  def change
    add_column :clocks, :left, :text
    add_column :clocks, :right, :text
  end
end
