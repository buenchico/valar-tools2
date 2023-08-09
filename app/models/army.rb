class Army < ApplicationRecord
  has_and_belongs_to_many :factions

  validates :name, presence: true
  validates :group, inclusion: { in: [nil] + ARMY_GROUPS.keys.map { |k| k.to_s }  }, allow_blank: true
  validates :status, inclusion: ARMY_STATUS
  validates_uniqueness_of :name
#  validates :tags, inclusion: Tool.find_by(name: 'armies').game_tools.find_by(game_id: Game.find_by(active: true).id).options["tags"].keys

  def strength
    @options = Tool.find_by(name: 'armies').game_tools.find_by(game_id: Game.find_by(active: true).id).options
    base = 10
    @options["attributes"].sort_by { |_, v| v["sort"] }.to_h.each do | key, value |
      base += self["col#{value['sort']}"].to_i * value["str"]
    end
    self.tags.each do | tag |
      base += @options["tags"].sort_by { |_, v| v["colour"] }.to_h[tag]["str"].to_i
    end
    str = base * self.hp / 100
    return str
  end
end
