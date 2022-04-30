class Game < ApplicationRecord
  has_and_belongs_to_many :tool
  accepts_nested_attributes_for :tool
end
