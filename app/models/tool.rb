class Tool < ApplicationRecord
  has_and_belongs_to_many :game
  accepts_nested_attributes_for :game
end
