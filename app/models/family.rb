class Family < ApplicationRecord
  belongs_to :game
  belongs_to :faction, optional: true
  has_many :locations
  belongs_to :lord, class_name: 'Family', foreign_key: 'lord_id', optional: true
  has_many :vassals, class_name: 'Family', foreign_key: 'lord_id'

  validates :name, presence: true
  validates :name, uniqueness: { scope: :game }

  def title
    self.name +
    if self.branch.empty?
      ""
    else
      " (" + self.branch + ")"
    end
  end
end
