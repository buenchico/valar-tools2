class ChangeDefaultVisibleForClocks < ActiveRecord::Migration[7.0]
  def change
    change_column_default :clocks, :visible, false
  end
end
