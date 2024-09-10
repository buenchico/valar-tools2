class Tool < ApplicationRecord
  validates :name, :title, :short_title, :icon_url, presence: true
  validates :name, :short_title, format: { without: /\s/ }
  validates :role, inclusion: { in: USER_ROLES}
  validates_uniqueness_of :name

  has_many :game_tools, :dependent => :destroy
  has_many :games, -> { order('name ASC') }, :through => :game_tools
  accepts_nested_attributes_for :game_tools
  accepts_nested_attributes_for :games

  after_create :add_all_games

  def path
    "/" + self.name
  end

  def active_games
    games.where((self.table_name_prefix + 'game_tools').to_sym => { active: true })
  end

  private
    def add_all_games
      self.games = Game.all unless games.present?
    end
end
