class CreateFamiliesLocations < ActiveRecord::Migration[7.0]
  def change
    add_reference :armies, :region
    add_reference :armies, :lord
  end
end
