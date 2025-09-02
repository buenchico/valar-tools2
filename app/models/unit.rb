class Unit < ApplicationRecord
  has_and_belongs_to_many :factions
  belongs_to :army, optional: true
  belongs_to :family, class_name: 'Family', foreign_key: 'family_id', optional: true
  belongs_to :location, class_name: 'Location', foreign_key: 'location_id', optional: true
end
