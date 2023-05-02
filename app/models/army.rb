class Army < ApplicationRecord
  has_and_belongs_to_many :factions
  validates :group, inclusion: { in: ['suit-diamond','square','circle','triangle','hexagon','octagon'] }

end
