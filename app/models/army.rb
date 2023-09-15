class Army < ApplicationRecord
  has_and_belongs_to_many :factions
  belongs_to :family, class_name: 'Family', foreign_key: 'family_id', optional: true
  belongs_to :location, class_name: 'Location', foreign_key: 'location_id', optional: true

  before_validation :set_options

  validates :name, presence: true
  validates :group, inclusion: { in: [nil] + ARMY_GROUPS.keys.map { |k| k.to_s }  }, allow_blank: true
  validates :status, inclusion: ARMY_STATUS
  validates_uniqueness_of :name
  validates :board, inclusion: { in: $options["fleets"]&.keys.map(&:to_s) }, allow_nil: true
  validates :tags, inclusion: { in: $options["tags"]&.keys.map(&:to_s) }, allow_nil: true

  def set_options
    $options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
  end

  def strength
    base = 10
    $options["attributes"].sort_by { |_, v| v["sort"] }.to_h.each do | key, value |
      base += self["col#{value['sort']}"].to_i * value["str"]
    end
    self.tags.each do | tag |
      if self.board.present? && $options["tags"][tag]["board"].present?
        base += $options["tags"].sort_by { |_, v| v["colour"] }.to_h.fetch(tag, {"board" => 0})["board"].to_i
      else
        base += $options["tags"].sort_by { |_, v| v["colour"] }.to_h.fetch(tag, {"str" => 0})["str"].to_i
      end
    end
    if self.board.present?
      base += $options["fleets"].fetch(self.board, {"str" => 0})["str"].to_i
    end
    str = base * self.hp / 100
    str = [0, str].max
    return str
  end
end
