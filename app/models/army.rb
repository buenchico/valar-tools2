class Army < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :group, :position, :notes, :search]

  has_and_belongs_to_many :factions
  belongs_to :family, class_name: 'Family', foreign_key: 'family_id', optional: true
  belongs_to :location, class_name: 'Location', foreign_key: 'location_id', optional: true

  has_many :units, dependent: :destroy
  accepts_nested_attributes_for :units, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true
  validates_uniqueness_of :name

  attr_accessor :faction_ids_was
  attr_accessor :unit_ids_was

  before_save :log_changes

  def title
    self.name
  end

  def strength
    units.sum(&:strength).to_i
  end

  def men
    units.sum(&:men).to_i
  end

  def search
    self.family&.name
  end

  def log_changes
    current_user = Thread.current[:current_user] || User.find_by(player: "valar")

    if self.changes.keys != ['logs'] # Check if the only changes are not of the logs
      puts "22222"
      puts .....
      if new_record?
        changes << "Army has been created"

        excluded = %w[family_id logs]
        changes = self.attributes.except(*excluded)
                         .select { |_, value| value.present? }
                         .map { |attr, value| "#{attr} is #{value.inspect}" }
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

private
  def set_options
    active_game = Game.find_by(active: true)
    @option_armies = Tool.find_by(name: "armies").game_tools.find_by(game_id: active_game&.id)&.options

    @units = @option_armies["units"]
  end
end
