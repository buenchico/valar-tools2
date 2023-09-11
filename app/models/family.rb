class Family < ApplicationRecord
  belongs_to :game
  belongs_to :faction, optional: true
  has_many :locations
  belongs_to :lord, class_name: 'Family', foreign_key: 'lord_id', optional: true
  has_many :vassals, class_name: 'Family', foreign_key: 'lord_id'
  has_many :armies, foreign_key: 'family_id'

  validates :name, presence: true
  validate :unique_name_and_branch_within_game

  def title
    if (self.branch.nil? || self.branch.empty?)
      self.name
    else
      self.name + " (" + self.branch + ")"
    end
  end

  def unique_name_and_branch_within_game
    if Family.exists?(game_id: game_id, name: name, branch: branch)
      errors.add(:base)
    end
  end
end
