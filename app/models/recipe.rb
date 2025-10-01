class Recipe < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :section, :description, :factors, :results]

  before_validation :set_options

  validates :name, presence: true
  validates :section, presence: true
  validates :difficulty, inclusion: { in: -6..3 }
  validates :speed, inclusion: { in: -1..5 }

  has_and_belongs_to_many :games

  SECTIONS = ["default"]

  validates :section, inclusion: { in: ->(recipe) { recipe.instance_variable_get(:@sections) || SECTIONS } }

  def title
    self.name
  end

  def active
    active_game = Game.find_by(active: true)
    if self.visible == true && self.games&.include?(active_game)
      true
    else
      false
    end
  end

private
  def set_options
    options = GameOptionsService.fetch
    @option_missions = options[:missions]

    @sections = @option_missions["sections"]
  end
end
