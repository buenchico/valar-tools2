class Unit < ApplicationRecord
  has_and_belongs_to_many :factions
  belongs_to :army, optional: true
  belongs_to :family, class_name: 'Family', foreign_key: 'family_id', optional: true
  belongs_to :location, class_name: 'Location', foreign_key: 'location_id', optional: true

  before_create :set_count_start
  after_create :generate_random_name
  after_update :track_count_changes

  validates :unit_type, presence: true
  validates :count, presence: true
  validates :strength_mod, presence: true
  validates :strength_indirect_mod, presence: true
  validates :hp_mod, presence: true
  validate :unique_name_within_faction

  def strength
    set_options if @options_armies.nil?
    unit_strength = @units.fetch(self.unit_type, {}).fetch("str", 0)

    return ((self.count.to_i * unit_strength.to_i * (self.strength_mod / 100.0)) / @army_scale).round(2)
  end

  def strength_indirect
    set_options if @options_armies.nil?
    unit_data = @units[self.unit_type] || {}
    unit_strength = unit_data["str_indirect"] || unit_data["str"] || 0

    return ((self.count.to_i * unit_strength.to_i * (self.strength_indirect_mod / 100.0)) / @army_scale).round(2)
  end

  def men
  end

  def men_start
  end

  def hp
  end

  def hp_start
  end

  def title
    set_options if @options_armies.nil?
    return (@units.fetch(self.unit_type, {}).fetch("name", "")).pluralize_all_words(self.count)
  end


  def icon
    set_options if @options_armies.nil?
    return @units.fetch(self.unit_type, {}).fetch("icon", nil)
  end

  def colour
    set_options if @options_armies.nil?
    return @army_types.fetch(self.army_type, {}).fetch("colour", "success")
  end

  def troops
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

    existing_count = 0
    self.factions.each do |faction|
      count = faction.units.where(unit_type: self.unit_type).count
      existing_count = [existing_count,count].max
    end

    self.name = "#{existing_count} #{self.unit_name} de #{self.title.singularize}"

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
end
