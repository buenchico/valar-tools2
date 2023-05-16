class Army < ApplicationRecord
  has_and_belongs_to_many :factions

  validates :name, :visible, presence: true
  validates :group, inclusion: { in: [nil] + ARMY_GROUPS.keys.map { |k| k.to_s }  }, allow_blank: true
  validates :status, inclusion: ARMY_STATUS
  validates_uniqueness_of :name
  validates :tags, inclusion: Tool.find_by(name: 'armies').game_tools.find_by(game_id: Game.find_by(active: true).id).options["tags"].keys

  def strength
    @options = Tool.find_by(name: 'armies').game_tools.find_by(game_id: Game.find_by(active: true).id).options
    str = 10
    @options["attributes"].each_with_index do | (key, value), index |
      str += self["col#{index}"].to_i * value["str"]
    end
    self.tags.each do | tag |
      str += @options["tags"][tag]["str"].to_i
    end
    return str
  end
end
