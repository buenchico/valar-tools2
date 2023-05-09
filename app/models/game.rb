class Game < ApplicationRecord
  validates :name, :title, :prefix, :icon_url, presence: true
  validates :name, :short_title, format: { without: /\s/ }

  has_many :factions

  has_many :game_tools, :dependent => :destroy
  has_many :tools, -> { order('sort ASC, name ASC') }, :through => :game_tools
  accepts_nested_attributes_for :game_tools

  after_create :add_all_tools

  def active_tools
    tools.where(game_tools: { active: true }).where(active: true)
  end

private
  def add_all_tools
    self.tools = Tool.all unless tools.present?
  end
end
