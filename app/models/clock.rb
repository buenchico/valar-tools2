class Clock < ApplicationRecord
  before_validation :set_options

  belongs_to :family, optional: true

  scope :closed, -> {
    where("(style = 'clock' AND status = size) OR (style = 'scale' AND ABS(status) = (size / 2)) OR (style = 'memory')")
  }

  scope :open, -> {
    where.not("(style = 'clock' AND status = size) OR (style = 'scale' AND ABS(status) = (size / 2)) OR (style = 'memory')")
  }

  # Instance method to check if the clock is closed
  def closed?
    (style == 'clock' && status == size) ||
    (style == 'scale' && status.abs == (size / 2)) ||
    (style == 'memory')
  end

  # Instance method to check if the clock is open
  def open?
    !closed?
  end

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
    active_game = Game.find_by(active: true)
    options = Tool.find_by(name: "clocks").game_tools.find_by(game_id: active_game&.id)&.options
    SIZES.replace(options["sizes"].map { |s| s["size"] })
  end

  def validate_status_for_clock_style
    if style == 'clock'
      unless status >= 0 && status <= size
        errors.add(:status, I18n.t('errors.messages.status_clock_style'))
      end
    end
  end

  def validate_status_for_balance_style
    if style == 'scale'
      unless status >= -(size/2) && status <= (size/2)
        errors.add(:status, I18n.t('errors.messages.status_balance_style'))
      end
    end
  end

end
