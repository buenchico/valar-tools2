class Game < ApplicationRecord
  has_and_belongs_to_many :tools, -> { order(id: :asc) }
  accepts_nested_attributes_for :tools

  has_many :factions
end
