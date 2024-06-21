class Army < ApplicationRecord
  before_validation :set_options

  has_and_belongs_to_many :factions
  belongs_to :family, class_name: 'Family', foreign_key: 'family_id', optional: true
  belongs_to :location, class_name: 'Location', foreign_key: 'location_id', optional: true

  validates :name, presence: true
  validates_uniqueness_of :name
  validates :group, inclusion: { in: [nil] + ARMY_GROUPS.keys.map { |k| k.to_s }  }, allow_blank: true

  attr_accessor :faction_ids_was

  ARMY_STATUS = ["raised", "active", "inactive"]
  FLEET_TYPES = [nil, "longship", "galley", "transport"]

  before_save :log_changes

  def set_options
    if $options_armies.present?
      ARMY_STATUS.replace($options_armies["status"].keys)
      FLEET_TYPES.replace([nil] + $options_armies["fleets"].keys)
    end
  end

  validates :status, inclusion: ARMY_STATUS
  validates :board, inclusion: FLEET_TYPES

  def log_changes
    if self.persisted? && self.changes.keys != ['logs'] # Check if the record already exists (for updates) and if the only changes are not of the logs
      current_user = Thread.current[:current_user]
      if current_user.nil?
        current_user = User.find_by(player: "valar")
      end
      changes = self.changes.map do |field, values|
        if field.starts_with?("col")
          field_name = ($options_armies["attributes"].keys.find { |key| $options_armies["attributes"][key]["sort"] == field.slice(3).to_i })  || "no_name"
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

  def men
    base = $options_armies.fetch("soldiers", 1000)
    status = $options_armies.fetch("status", {}).fetch(self.status, {}).fetch("men", 1)
    men = base * status * self.hp.to_i / 100
    return men
  end

  def strength
    base = 10
    @options = $options_armies
    @options["attributes"].sort_by { |_, v| v["sort"] }.to_h.each do | key, value |
      base += self["col#{value['sort']}"].to_i * value["str"]
    end
    if self.tags.present?
      self.tags.each do | tag |
        if self.board.present? && @options["tags"]&.[](tag)&.[]("board").present?
          base += @options["tags"].sort_by { |_, v| v["colour"] }.to_h.fetch(tag, {"board" => 0})["board"].to_i
        else
          base += @options["tags"].sort_by { |_, v| v["colour"] }.to_h.fetch(tag, {"str" => 0})["str"].to_i
        end
      end
    end
    if self.board.present?
      base += @options["fleets"].fetch(self.board, {"str" => 0})["str"].to_i
    end
    str = base * self.hp.to_i / 100
    str = [0, str].max
    status = @options.fetch("status", {}).fetch(self.status, {}).fetch("str", 1)
    str = str * status
    return str
  end
end
