class Army < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :group, :position, :notes, :search]

  has_many :units, dependent: :destroy
  has_and_belongs_to_many :factions
end
