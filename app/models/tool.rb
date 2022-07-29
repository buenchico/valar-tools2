class Tool < ApplicationRecord
  has_and_belongs_to_many :game
  accepts_nested_attributes_for :game

  validates :name, :title, :short_title, :icon_url, presence: true
  validates :name, :short_title, format: { without: /\s/ }
  validates :role, inclusion: { in: ['player', 'master', 'admin']}

  def path
    "/" + self.name
  end
end
