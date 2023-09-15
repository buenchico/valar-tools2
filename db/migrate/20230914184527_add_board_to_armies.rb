class AddBoardToArmies < ActiveRecord::Migration[7.0]
  def change
    add_column :armies, :board, :string    
  end
end
