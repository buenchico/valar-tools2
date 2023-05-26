class Family < ApplicationRecord
  belongs_to :game
  has_many :locations

  validates :name, presence: true
  validates :name, uniqueness: { scope: :game }

  def title
    self.name
  end
end
