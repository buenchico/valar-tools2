class Family < ApplicationRecord
  belongs_to :game
  belongs_to :faction, optional: true
  has_many :locations

  validates :name, presence: true
  validates :name, uniqueness: { scope: :game }

  def title
    self.name
  end
end
