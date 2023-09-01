class Family < ApplicationRecord
  belongs_to :game
  belongs_to :faction, optional: true
  has_many :locations
  belongs_to :lord, class_name: 'Family', foreign_key: 'lord_id', optional: true
  has_many :vassals, class_name: 'Family', foreign_key: 'lord_id'
  has_many :armies, foreign_key: 'family_id'

  validates :name, presence: true
  validates :name, uniqueness: { scope: :game }

  def title
    if (self.branch.nil? || self.branch.empty?)
      self.name
    else
      self.name + " (" + self.branch + ")"
    end
  end
end
