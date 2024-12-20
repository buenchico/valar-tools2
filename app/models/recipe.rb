class Recipe < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :section, :description, :factors, :results]

  before_validation :set_options

  validates :name, presence: true
  validates :section, presence: true
  validates :difficulty, inclusion: { in: -6..3 }
  validates :speed, inclusion: { in: -1..4 }

  SECTIONS = ["default"]

  def set_options
    active_game = Game.find_by(active: true)
    @option_recipes = Tool.find_by(name: "missions").game_tools.find_by(game_id: active_game&.id)&.options

    @sections = @option_recipes["sections"]
  end

  validates :section, inclusion: { in: ->(recipe) { recipe.instance_variable_get(:@sections) || SECTIONS } }

  def title
    self.name
  end

  def visible
    true
  end
end
