class Army < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :position, :notes, :search]

  has_many :units, dependent: :destroy
  has_and_belongs_to_many :factions

  def search
   nil
  end

  def army_type
    units.first.army_type
  end
end
