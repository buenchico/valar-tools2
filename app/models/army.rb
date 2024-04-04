class Army < ApplicationRecord
  has_and_belongs_to_many :factions
  belongs_to :family, class_name: 'Family', foreign_key: 'family_id', optional: true
  belongs_to :location, class_name: 'Location', foreign_key: 'location_id', optional: true

  validates :name, presence: true
  validates :group, inclusion: { in: [nil] + ARMY_GROUPS.keys.map { |k| k.to_s }  }, allow_blank: true

  if $options_armies.nil?
    ARMY_STATUS = ["raised","active","inactive"]
    FLEET_TYPES = [nil, "longship","galley","transport"]
  else
    ARMY_STATUS = $options_armies["status"].keys
    FLEET_TYPES = [nil] + $options_armies["fleets"].keys
  end

  validates :status, inclusion: ARMY_STATUS
  validates :board, inclusion: FLEET_TYPES
  validates_uniqueness_of :name

  before_save :log_changes

  def log_changes
    if self.persisted? # Check if the record already exists (for updates)
      current_user = Thread.current[:current_user]
      if current_user.nil?
        current_user = User.find_by(player: "valar")
      end
      changes = self.changes.map { |field, values| "#{field} changed from #{values[0].blank? ? "nil" : values[0]} to #{values[1].blank? ? "nil" : values[1]}" }

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
    men = base * status * self.hp / 100
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
    str = base * self.hp / 100
    str = [0, str].max
    status = @options.fetch("status", {}).fetch(self.status, {}).fetch("str", 1)
    str = str * status
    return str
  end
end
