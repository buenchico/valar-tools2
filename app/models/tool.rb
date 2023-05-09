class Tool < ApplicationRecord
  validates :name, :title, :short_title, :icon_url, presence: true
  validates :name, :short_title, format: { without: /\s/ }
  validates :role, inclusion: { in: ['player', 'master', 'admin']}

  has_many :game_tools, :dependent => :destroy
  has_many :games, -> { order('name ASC') }, :through => :game_tools
  accepts_nested_attributes_for :game_tools

  after_create :add_all_games

  def path
    "/" + self.name
  end

  def active_games
    games.where(game_tools: { active: true })
  end

  private
    def add_all_games
      self.games = Game.all unless games.present?
    end
end
