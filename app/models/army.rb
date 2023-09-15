class Army < ApplicationRecord
  has_and_belongs_to_many :factions
  belongs_to :family, class_name: 'Family', foreign_key: 'family_id', optional: true
  belongs_to :location, class_name: 'Location', foreign_key: 'location_id', optional: true

  validates :name, presence: true
  validates :group, inclusion: { in: [nil] + ARMY_GROUPS.keys.map { |k| k.to_s }  }, allow_blank: true
  validates :status, inclusion: ARMY_STATUS
  validates_uniqueness_of :name
#  validates :tags, inclusion: Tool.find_by(name: 'armies').game_tools.find_by(game_id: Game.find_by(active: true).id).options["tags"].keys

  def strength
    @options = $options
    base = 10
    @options["attributes"].sort_by { |_, v| v["sort"] }.to_h.each do | key, value |
      base += self["col#{value['sort']}"].to_i * value["str"]
    end
    self.tags.each do | tag |
      if self.board.present? &&  @options["tags"][tag]["board"].present?
        base += @options["tags"].sort_by { |_, v| v["colour"] }.to_h.fetch(tag, {"board" => 0})["board"].to_i
      else
        base += @options["tags"].sort_by { |_, v| v["colour"] }.to_h.fetch(tag, {"str" => 0})["str"].to_i
      end
    end
    if self.board.present?
      base += @options["fleets"].fetch(self.board, {"str" => 0})["str"].to_i
    end
    str = base * self.hp / 100
    return str
  end
end
