class AddLogsToArmies < ActiveRecord::Migration[7.0]
  def change
    add_column :armies, :logs, :text, array: true, default: []
  end
end
