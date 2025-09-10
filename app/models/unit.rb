class Unit < ApplicationRecord
  has_and_belongs_to_many :factions
  belongs_to :army, optional: true
  belongs_to :family, class_name: 'Family', foreign_key: 'family_id', optional: true
  belongs_to :location, class_name: 'Location', foreign_key: 'location_id', optional: true

  attr_accessor :faction_ids_was

  validates :unit_type, presence: true
  validates :count, presence: true
  validates :strength_mod, presence: true
  validates :strength_indirect_mod, presence: true
  validates :hp_mod, presence: true
  validate :unique_name_within_faction

  before_create :set_count_start
  after_create :generate_random_name

  after_find :cache_factions

  after_update :track_count_changes

  before_save :log_changes

  def strength
    set_options if @options_armies.nil?
    unit_strength = @units.fetch(self.unit_type, {}).fetch("str", 0)

    return ((self.count.to_i * unit_strength.to_i * (self.strength_mod.to_f / 100)) / @army_scale).round(2)
  end

  def strength_indirect
    set_options if @options_armies.nil?
    unit_data = @units[self.unit_type] || {}
    unit_strength = unit_data["str_indirect"] || unit_data["str"] || 0

    return ((self.count.to_i * unit_strength.to_i * (self.strength_indirect_mod.to_f / 100)) / @army_scale).round(2)
  end

  def men
    set_options if @options_armies.nil?

    unit_men = @units.fetch(self.unit_type, {}).fetch("men", 0)

    return (self.count.to_i * unit_men).to_i
  end

  def men_start
    set_options if @options_armies.nil?

    unit_men = @units.fetch(self.unit_type, {}).fetch("men", 0)

    return (self.count_start.to_i * unit_men).to_i
  end

  def men_death
    set_options if @options_armies.nil?

    unit_men = @units.fetch(self.unit_type, {}).fetch("men", 0)

    return (self.count_death.to_i * unit_men).to_i
  end

  def hp
    (self.count.to_i * self.hp_per_unit).to_i
  end

  def hp_start
    (self.count_start.to_i * self.hp_per_unit).to_i
  end

  def hp_per_unit
    set_options if @options_armies.nil?

    unit_hp = @units.fetch(self.unit_type, {}).fetch("hp", 0)

    return (unit_hp * self.hp_mod * 0.01).round(2)
  end

  def title
    set_options if @options_armies.nil?
    title = (@units.fetch(self.unit_type, {}).fetch("name", "")).pluralize_all_words(self.count)
    message = []
    if strength_mod != 100
      message << "🎖" + (strength_mod/100.0).round(1).to_s
    end
    if strength_indirect_mod != 100
      message << "𖦏" + (strength_indirect_mod/100.0).round(1).to_s
    end
    if hp_mod != 100
      message << "❤︎" + (hp_mod/100.0).round(1).to_s
    end

    if message.present?
      title += " (" + message.join(", ") + ")"
    end

    return title
  end


  def icon
    set_options if @options_armies.nil?
    return @units.fetch(self.unit_type, {}).fetch("icon", nil)
  end

  def colour
    set_options if @options_armies.nil?
    return @army_types.fetch(self.army_type, {}).fetch("colour", "success")
  end

  def army_type
    set_options if @options_armies.nil?
    return @units.fetch(self.unit_type, {}).fetch("type", nil)
  end

  def army_icon
    set_options if @options_armies.nil?
    return @army_types.fetch(self.army_type, {}).fetch("icon", "")
  end

  def unit_name
    set_options if @options_armies.nil?
    return @army_types.fetch(self.army_type, {}).fetch("unit", "")
  end

private
  def set_options
    active_game = Game.find_by(active: true)
    @options_armies = Tool.find_by(name: "armies").game_tools.find_by(game_id: active_game&.id)&.options

    @units = @options_armies["units"]
    @army_types = @options_armies["army_type"]&.sort_by { |_, v| v["sort"] }.to_h
    @status = @options_armies["status"]
    @army_scale = @options_armies["general"]["scale"]
  end

  def track_count_changes
    return unless saved_change_to_count?

    old_count, new_count = saved_change_to_count

    if new_count < old_count
      self.count_death = (count_death || 0) + (old_count - new_count)
    elsif new_count > old_count
      self.count_start = (count_start || 0) + (new_count - old_count)
    end

    # Save without triggering another callback
    save(validate: false, touch: false)
  end

  def set_count_start
    self.count_start = self.count
  end

  def generate_random_name
    return unless name.blank?

    existing_count = 1
    base_name = "#{unit_name} de #{title.singularize}"

    loop do
      candidate_name = "#{existing_count} #{base_name}"

      # Check if any faction already has a unit with this name and type
      conflict = self.factions.any? do |faction|
        faction.units.where(unit_type: unit_type, name: candidate_name).exists?
      end

      if conflict
        existing_count += 1
      else
        self.name = candidate_name
        break
      end
    end

    save(validate: false, touch: false)
  end

  def unique_name_within_faction
    return unless name.present?

    factions.each do |faction|
      if faction.units.where(name: name).where.not(id: id).exists?
        errors.add(:name, :taken_in_faction, faction: faction.name)
      end
    end
  end

  def cache_factions
    self.faction_ids_was = self.faction_ids.dup
  end

  def log_changes
    excluded_keys = ["updated_at", "created_at", "logs"]
    association_fields = {
      "family_id" => Family,
      "location_id" => Location,
      "army_id" => Army
    }

    message = []

    current_user = Thread.current[:current_user] || User.find_by(player: "valar")

    if self.changes.keys != ['logs'] # Check if the only changes are not of the logs
      changes.each do |attr, (old, new)|
        next if excluded_keys.include?(attr)

        if association_fields.key?(attr)
          model = association_fields[attr]
          old_name = model.find_by(id: old)&.name || "None"
          new_name = model.find_by(id: new)&.name || "None"
          message << "Unit ##{id || "None"} - #{attr.gsub('_id', '')} changed from '#{old_name}' to '#{new_name}'"
        else
          message << "Unit ##{id || "None"} - #{attr || "None"} changed from #{old || "None"} to #{new || "None"}"
        end
      end

      if self.faction_ids_was&.sort != faction_ids&.sort
        old_names = Faction.where(id: self.faction_ids_was&.sort).pluck(:name).join(", ")
        new_names = Faction.where(id: faction_ids).pluck(:name).join(", ")
        message << "Unit ##{id} - factions changed from '#{old_names}' to '#{new_names}'"
      end

      change_log = {
        timestamp: Time.now,
        user_id: current_user.id, # Set the current user appropriately
        username: current_user.player,
        changes: message
      }

      # Initialize self.logs as an empty array if it's nil
      self.logs ||= []

      # Append the change log to the "logs" array
      self.logs << change_log.to_json
    end
  end
end
