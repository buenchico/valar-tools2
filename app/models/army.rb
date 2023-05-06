class Army < ApplicationRecord
  has_and_belongs_to_many :factions
  validates :group, inclusion: { in: [nil] + ARMY_GROUPS.keys.map { |k| k.to_s }  }, allow_blank: true

end
