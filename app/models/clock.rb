class Clock < ApplicationRecord
  before_validation :set_options

  belongs_to :family, optional: true
  validate :validate_status_for_clock_style
  validate :validate_status_for_balance_style

  STYLES = ["clock", "scale"]
  SIZES = [4, 6, 8]
  OUTCOMES = [-1 , 0 , 1]

  validates :style, inclusion: { in: STYLES}
  validates :size, inclusion: { in: SIZES }
  validates :outcome, inclusion: { in: OUTCOMES }

private
  def set_options
    active_game = Game.find_by(active: true)
    options = Tool.find_by(name: "clocks").game_tools.find_by(game_id: active_game&.id)&.options
    SIZES.replace(options["sizes"].map { |s| s["size"] })
  end

  def validate_status_for_clock_style
    if style == 'clock'
      unless status >= 0 && status <= size
        errors.add(:status, "must be greater or equal to 0 and smaller or equal to size for clock style")
      end
    end
  end

  def validate_status_for_balance_style
    if style == 'scale'
      unless status >= -size && status <= size
        errors.add(:status, "must be greater or equal to negative size and smaller or equal to size for balance style")
      end
    end
  end

end
