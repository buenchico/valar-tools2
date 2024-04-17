class Battle < ApplicationRecord
  belongs_to :user

  validates_uniqueness_of :name
  validates :date, presence: true
  validates :terrain, presence: true
  validates :sideA, presence: true
  validates :sideB, presence: true

  if $options_battles.nil?
    BATTLE_STATUS = ["draft", "skirmish", "engagement", "combat_1", "combat_2", "combat_3", "result"]
  else
    BATTLE_STATUS = $options_battles["status"].sort_by { |key, value| value["sort"] }.to_h.keys
  end

  validates :status, inclusion: BATTLE_STATUS
end
