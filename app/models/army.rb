class Army < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :group, :position, :notes, :families, :locations]

  has_many :units, dependent: :nullify
  accepts_nested_attributes_for :units, allow_destroy: true

  attr_accessor :unit_ids_was

  validate :must_have_at_least_one_unit
  validates :name, presence: true, uniqueness: true
  validates :xp, numericality: { greater_than_or_equal_to: 50 }
  validates :morale, numericality: { greater_than_or_equal_to: 0 }
  validates :group, inclusion: { in: [nil] + ARMY_GROUPS.keys.map { |k| k.to_s }  }, allow_blank: true

  after_find :cache_units

  before_validation :ensure_minimum_xp
  before_validation :ensure_minimum_morale

  before_save :annihilate
  before_save :log_changes

  def title
    self.name
  end

  def size
    set_options if @options_armies.nil?

    (self.men / (@army_scale * 10))
  end

  def strength
    set_options if @options_armies.nil?

    units = self.units.sum(&:strength)

    multiplier = ((self.xp.to_f / 100.0) * (self.morale.to_f / 100.0)).round(2)

    self.tags.each do |tag|
      multiplier = (@army_tags.fetch(tag, {}).fetch("str", 1) * multiplier)
    end

    (units * multiplier)
  end

  def strength_indirect
    set_options if @options_armies.nil?

    units = self.units.sum(&:strength_indirect)

    multiplier = ((self.xp.to_f / 100.0) * (self.morale.to_f / 100.0)).round(2)

    self.tags.each do |tag|
      multiplier = (@army_tags.fetch(tag, {}).fetch("str_indirect", 1) * multiplier)
    end

    (units * multiplier)
  end

  def men
    units.sum(&:men).to_i
  end

  def men_start
    units.sum(&:men_start).to_i
  end

  def men_death
    units.sum(&:men_death).to_i
  end

  def hp
    units.sum(&:hp).to_i
  end

  def hp_start
    units.sum(&:hp_start).to_i
  end

  def speed
    self.units.map(&:speed).max
  end

  def speed_name
    set_options if @options_armies.nil?

    value = self.speed

    @speeds.select { |item| item["mod"] <= value }
      .max_by { |item| item["mod"] }["name"]
  end

  def families
    self.units.includes(:family).map(&:family).compact.uniq.sort_by(&:title)
  end

  def locations
    self.units.includes(:location).map(&:location).compact.uniq.sort_by(&:name)
  end

  def factions
    self.units.includes(:factions).flat_map(&:factions).uniq.sort_by(&:name)
  end

  def unit_tags
    units.flat_map(&:tags).compact.sort.tally
  end

  def army_type
    units&.first&.army_type
  end

  def icon
    units&.first&.army_icon
  end

  def colour
    units&.first&.colour
  end

private
  def set_options
    active_game = Game.find_by(active: true)
    @options_armies = Tool.find_by(name: "armies").game_tools.find_by(game_id: active_game&.id)&.options
    @speeds = Tool.find_by(name: "travel").game_tools.find_by(game_id: active_game&.id)&.options.fetch("speed", [])

    @units = @options_armies["units"]
    @army_tags = @options_armies.fetch("army_tags", {})
    @army_types = @options_armies["army_type"]&.sort_by { |_, v| v["sort"] }.to_h
    @status = @options_armies["status"]
    @army_scale = @options_armies["general"]["scale"]
  end

  def must_have_at_least_one_unit
    if units.empty? || units.all?(&:marked_for_destruction?)
      errors.add(:units, I18n.t('activerecord.errors.models.army.attributes.units.must_include_one'))
    end
  end

  def ensure_minimum_xp
    self.xp = 50 if xp.present? && xp < 50
  end

  def ensure_minimum_morale
    self.morale = 0 if morale.present? && morale < 0
  end

  def cache_units
    self.unit_ids_was = self.unit_ids.dup
  end

  def annihilate
    if self.status == "inactive"
      self.units.each do |unit|
        unit.update(count: 0)
      end
    end
  end

  def log_changes
    excluded_keys = ["updated_at", "created_at", "logs"]
    association_fields = { }

    message = []

    current_user = Thread.current[:current_user] || User.find_by(player: "valar")

    if self.changes.keys != ['logs'] # Check if the only changes are not of the logs
      changes.each do |attr, (old, new)|
        next if excluded_keys.include?(attr)

        if association_fields.key?(attr)
          model = association_fields[attr]
          old_names = model.find_by(id: old)&.name || "None"
          new_names = model.find_by(id: new)&.name || "None"
          message << "Army ##{id || "None"} - #{attr.gsub('_id', '')} changed from '#{old_name}' to '#{new_name}'"
        else
          message << "Army ##{id || "None"} - #{attr || "None"} changed from #{old || "None"} to #{new || "None"}"
        end
      end

      if self.unit_ids_was&.sort != unit_ids&.sort
        old_names = Unit.where(id: self.unit_ids_was&.sort).pluck(:name, :id).join(", ")
        new_names = Unit.where(id: unit_ids).pluck(:name).join(", ")
        message << "Army ##{id} - units changed from '#{old_names}' to '#{new_names}'"
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
