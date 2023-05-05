class AddOptionsInfoToTools < ActiveRecord::Migration[7.0]
  def change
    add_column :tools, :options_info, :text
  end
end
