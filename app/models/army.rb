class Army < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :group, :position, :notes, :search]

  before_validation :set_options
  before_validation :clean_tags # New callback to clean empty elements in :tags

  has_and_belongs_to_many :factions
  belongs_to :family, class_name: 'Family', foreign_key: 'family_id', optional: true
  belongs_to :location, class_name: 'Location', foreign_key: 'location_id', optional: true

  validates :name, presence: true
  validates_uniqueness_of :name
  validates :group, inclusion: { in: [nil] + ARMY_GROUPS.keys.map { |k| k.to_s }  }, allow_blank: true

  before_create :set_hp_start

  attr_accessor :faction_ids_was

  ARMY_STATUS = ["raised", "active", "inactive"]
  ARMY_TYPE = ["conscript"]
  FLEET_TYPES = [nil, "longship", "galley", "transport"]

  before_save :log_changes

  def search
    self.family&.name
  end

  def clean_tags
    self.tags = self.tags.reject(&:blank?) if self.tags.is_a?(Array)
  end

  def set_options
    active_game = Game.find_by(active: true)
    @option_armies = Tool.find_by(name: "armies").game_tools.find_by(game_id: active_game&.id)&.options

    @army_status = @option_armies["status"].keys
    @fleet_types = [nil] + @option_armies["fleets"].keys
    @army_type = @option_armies["army_type"].keys
  end

  validates :status, inclusion: { in: ->(army) { army.instance_variable_get(:@army_status) || ARMY_STATUS } }
  validates :board, inclusion: { in: ->(army) { army.instance_variable_get(:@fleet_types) || FLEET_TYPES } }
  validates :army_type, inclusion: { in: ->(army) { army.instance_variable_get(:@army_type) || ARMY_TYPE } }

  def log_changes
    if self.persisted? && self.changes.keys != ['logs'] # Check if the record already exists (for updates) and if the only changes are not of the logs
      current_user = Thread.current[:current_user]
      if current_user.nil?
        current_user = User.find_by(player: "valar")
      end
      changes = self.changes.map do |field, values|
        if field.starts_with?("attr")
          field_name = (@option_armies["attributes"].keys.find { |key| @option_armies["attributes"][key]["sort"] == field.slice(3).to_i })  || "no_name"
          field = field_name + "(" + field + ")"
        end
        if field.starts_with?("men")
          field_name = (@option_armies["men"].keys.find { |key| @option_armies["men"][key]["sort"] == field.slice(3).to_i })  || "no_name"
          field = field_name + "(" + field + ")"
        end
        "#{field} changed from #{values[0].blank? ? "nil" : values[0]} to #{values[1].blank? ? "nil" : values[1]}"
      end
      if self.faction_ids_was != self.faction_ids
        changes << ("Factions changed from: " + Faction.where(id: self.faction_ids_was).pluck(:name, :id).map { |name, id| "#{name} (#{id})" }.to_s + " to: " + Faction.where(id: self.faction_ids).pluck(:name, :id).map { |name, id| "#{name} (#{id})" }.to_s)
      end

      change_log = {
        timestamp: Time.now,
        user_id: current_user.id, # Set the current user appropriately
        username: current_user.player,
        changes: changes
      }

      # Initialize self.logs as an empty array if it's nil
      self.logs ||= []

      # Append the change log to the "logs" array
      self.logs << change_log.to_json
    end
  end

  def men0
    return composition[0] * 0.1
  end

  def composition
    set_options if @option_armies.nil?

    status = @option_armies.fetch("status", {}).fetch(self.status, {}).fetch("men", 1)
    fill = @option_armies.fetch("army_type", {}).fetch(self.army_type, {}).fetch("fill", 1)
    composition = []

    @option_armies.fetch("men", {})&.sort_by { |_, v| v["sort"] }.to_h.each do | key, value |
      if key != "default"
        troops = (value["men"] || 10)
        number = (self["men#{value['sort']}"] || 0)

        composition << (number * troops * status).to_i
      end
    end

    if fill == 1
      troops = (100 - composition.sum)
    else
      troops = 0
    end

    composition.unshift(troops * status)

    return composition
  end

  def men
    set_options if @option_armies.nil?

    base = @option_armies.fetch("soldiers", 1000)

    men = (self.composition.sum * self.hp * base * 0.01 * 0.01).to_i

    return men
  end

  def strength_calc(terrain = nil)
    set_options if @option_armies.nil?

    # If terrain is not provided, determine terrain based on self.board
    terrain ||= self.board.nil? ? "str" : "board"

    army_type = @option_armies.fetch("army_type", {}).fetch(self.army_type, {})

    base_str = army_type.fetch("str", 0)
    fill = army_type.fetch("fill", 1)

    tags = @option_armies.fetch("tags", {})&.sort_by { |key, _value| key }.to_h

    hp = (self.hp * 0.01).to_f

    men = @option_armies.fetch("men", {})&.sort_by { |_key, value| value["sort"] }.map { |_key, value| value[terrain] || value["str"] }

    men_str = []
    men.each_with_index do | value, index |
      men_str << (self.send("men#{index}").to_f * value)
    end

    tags_str = []
    self.tags.each do | tag |
      tags_str << tags.fetch(tag, {}).fetch(terrain, 0)
    end

    attributes = @option_armies.fetch("attributes", {})&.sort_by { |_key, value| value["sort"] }.map { |_key, value| value["str"] }

    attr = []
    attributes.each_with_index do | value, index |
      attr << self["attr#{index}"]
    end

    attr_mod = (attr.zip(attributes).map { |a, b| a.to_f * b.to_f})
    attr_str = 1
    attr_mod.each do | value |
      attr_str = attr_str * (100 + value) * 0.01
    end

    if terrain == "board"
      fleet_str = @option_armies.fetch("fleets", {})&.fetch(self.board, {})&.fetch("str", 0)
    else
      fleet_str = 0
    end

    subtotal = [(base_str + men_str.sum + tags_str.sum + fleet_str), 0].max

    str_total = ( subtotal * attr_str * hp).round(2)

    str = { "total": str_total, "subtotal": subtotal, "type": base_str, "men": men_str, "tags": tags_str, "attributes": attr_mod, "fleet": fleet_str, "hp": hp, "terrain": terrain}

    return str
  end

  def strength
    self.strength_calc[:total]
  end

private
  # Method to set hp_start to the value of hp
  def set_hp_start
    self.hp_start = self.hp
  end
end
