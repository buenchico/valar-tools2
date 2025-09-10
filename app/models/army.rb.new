class Army < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :group, :position, :notes, :search]

  has_and_belongs_to_many :factions
  belongs_to :family, class_name: 'Family', foreign_key: 'family_id', optional: true
  belongs_to :location, class_name: 'Location', foreign_key: 'location_id', optional: true

  has_many :units, dependent: :destroy
  accepts_nested_attributes_for :units, reject_if: :all_blank, allow_destroy: true

  before_validation :set_options

  validates :name, presence: true
  validates_uniqueness_of :name
  validate :army_type_must_be_valid

  attr_accessor :faction_ids_was
  attr_accessor :unit_ids_was

  after_find :cache_attributes
  before_save :log_changes

  def title
    self.name
  end

  def strength
    self.strength_calc[:total]
  end

  def strength_calc
    set_options if @options_armies.nil?

    units = self.units.sum(&:strength)

    mult = (self.xp / 100) * (self.morale / 100).to_i

    tags = 0

    total = units * mult

    str = { "total": total.round(2), "subtotal": units.round(2), "mult": mult, "tags": tags }

    return str
  end

  def men
    units.sum(&:men).to_i
  end

  def men_start
    units.sum(&:men_start).to_i
  end

  def hp
    units.sum(&:hp).to_i
  end

  def hp_start
    units.sum(&:hp_start).to_i
  end

  def search
    self.family&.name
  end

  def log_changes
    current_user = Thread.current[:current_user] || User.find_by(player: "valar")

    if self.changes.keys != ['logs'] # Check if the only changes are not of the logs
      if new_record?
        changes = ["Army has been created"]

        excluded = %w[family_id logs]
        changes.concat(self.attributes.except(*excluded)
                         .select { |_, value| value.present? }
                         .map { |attr, value| "#{attr} is #{value.inspect}" })
        if self.family_id.present?
          changes << "family is #{Family.find(self.family_id)&.title}"
        end

        if self.faction_ids.present?
          changes << "factions is #{Faction.where(id: faction_ids).pluck(:name, :id).map { |name, id | "#{name} (#{id})" }.to_s }"
        end

        if unit_ids.present?
          self.units.each do | unit |
            changes << "Unit added : #{unit.count} #{unit.name}"
          end
        end
      else
        excluded = %w[logs]
        changes = self.changes.except(*excluded).map do |field, values|
          if field == "family_id"
            "#{field} changed from #{values[0].blank? ? "nil" : Family.find(values[0])&.title} to #{values[1].blank? ? "nil" : Family.find(values[1])&.title}"
          else
            "#{field} changed from #{values[0].blank? ? "nil" : values[0]} to #{values[1].blank? ? "nil" : values[1]}"
          end
        end

        if self.faction_ids_was != self.faction_ids
          changes << ("Factions changed from: " + Faction.where(id: self.faction_ids_was).pluck(:name, :id).map { |name, id| "#{name} (#{id})" }.to_s + " to: " + Faction.where(id: self.faction_ids).pluck(:name, :id).map { |name, id| "#{name} (#{id})" }.to_s)
        end
      end

      units.each do |unit|
        if unit.new_record?
          changes << "Unit created : #{unit.unit_type}, count: #{unit.count}"
        elsif unit.marked_for_destruction?
          changes << "Unit (##{unit.id}) destroyed : #{unit.unit_type}, count: #{unit.count}"
        elsif unit.changed?
          unit_changes = unit.changes.map do |field, values|
            "#{field} changed from #{values[0].blank? ? "nil" : values[0]} to #{values[1].blank? ? "nil" : values[1]}"
          end
          changes << "Unit (##{unit.id}) : #{unit.unit_type} #{unit_changes.join(", ")}"
        end
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

  def set_options
    active_game = Game.find_by(active: true)
    @options_armies = Tool.find_by(name: "armies").game_tools.find_by(game_id: active_game&.id)&.options

    @units = @options_armies["units"]
    @status = @options_armies["status"]
    @army_types = @options_armies["army_type"]&.sort_by { |_, v| v["sort"] }.to_h
  end

  def army_type_must_be_valid
    valid_types = @army_types&.keys&.map(&:to_s) || []
    unless valid_types.include?(army_type)
      errors.add(:army_type, "is not a valid type. Must be one of: #{valid_types.join(', ')}")
    end
  end

  def cache_attributes
    self.faction_ids_was = self.faction_ids.dup
    self.unit_ids_was = self.unit_ids.dup
  end
end
