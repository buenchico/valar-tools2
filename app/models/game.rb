class Game < ApplicationRecord
  validates :name, :title, :prefix, :icon_url, presence: true
  validates :name, :prefix, format: { without: /\s/ }
  validates_uniqueness_of :name, :title

  has_and_belongs_to_many :factions

  has_many :game_tools, :dependent => :destroy
  has_many :tools, -> { order('sort ASC, name ASC') }, :through => :game_tools
  accepts_nested_attributes_for :game_tools

  has_many :families

  after_create :add_all_tools
  after_create :add_base_factions

  def active_tools
    tools.where((self.table_name_prefix + 'game_tools').to_sym => { active: true })
  end

private
  def add_all_tools
    self.tools = Tool.all unless tools.present?
  end

  def add_base_factions
    self.factions = Faction.limit(3)
  end
end
