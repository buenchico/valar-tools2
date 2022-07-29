class Faction < ApplicationRecord
  has_many :users
  belongs_to :game
  validates :name, presence: true, uniqueness: true, format: { without: /\s/ }

  def title
    if self.long_name.nil?
      self.name
    else
      self.long_name
    end
  end
end
