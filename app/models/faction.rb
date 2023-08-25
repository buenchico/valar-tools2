class Faction < ApplicationRecord
  has_many :users
  has_and_belongs_to_many :armies
  has_and_belongs_to_many :games
  validates :name, presence: true, uniqueness: true, format: { without: /\s/ }
  accepts_nested_attributes_for :games

  def title
    if self.long_name.nil?
      self.name
    else
      self.long_name
    end
  end
end
