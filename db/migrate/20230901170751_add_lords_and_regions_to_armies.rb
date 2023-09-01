class AddLordsAndRegionsToArmies < ActiveRecord::Migration[7.0]
  def change
    add_reference :armies, :location
    add_reference :armies, :family
  end
end
