class Clock < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :description, :left, :right, :search]

  before_validation :set_options

  belongs_to :family, optional: true

  validate :validate_status_for_clock_style
  validate :validate_status_for_balance_style

  STYLES = ["clock", "scale", "memory"]
  SIZES = [4, 6, 8]
  OUTCOMES = [-1 , 0 , 1]

  validates :style, inclusion: { in: STYLES}
  validates :size, inclusion: { in: SIZES }, unless: -> { style == "memory" }
  validates :outcome, inclusion: { in: OUTCOMES }

  validates :left, length: { maximum: 10 }
  validates :right, length: { maximum: 10 }

  before_save :log_changes

  def title
    self.name
  end

  def search
    self.family&.name
  end

  def size_h
    if self.style == 'memory'
      nil
    elsif self.style == 'clock'
      self.size
    elsif self.style == 'scale'
      (self.size / 2)
    end
  end

private
  def log_changes
    if self.persisted? && self.changes.keys != ['logs'] # Check if the record already exists (for updates) and if the only changes are not of the logs
      current_user = Thread.current[:current_user]
      if current_user.nil?
        current_user = User.find_by(player: "valar")
      end
      changes = self.changes.map do |field, values|
        "#{field} changed from #{values[0].blank? ? "nil" : values[0]} to #{values[1].blank? ? "nil" : values[1]}"
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
    options = GameOptionsService.fetch
    @options_clocks = options[:clocks]
    SIZES.replace(@options_clocks["sizes"].map { |s| s["size"] })
  end

  def validate_status_for_clock_style
    if style == 'clock'
      unless status >= 0 && status <= size.to_i
        errors.add(:status, I18n.t('errors.messages.status_clock_style'))
      end
    end
  end

  def validate_status_for_balance_style
    if style == 'scale'
      unless status >= -(size.to_i/2) && status <= (size.to_i/2)
        errors.add(:status, I18n.t('errors.messages.status_balance_style'))
      end
    end
  end

end
