class Clock < ApplicationRecord
  before_validation :set_options

  belongs_to :family, optional: true
  validates :status, numericality: { greater_than_or_equal_to: 0 }
  validate :status_less_than_or_equal_to_size

  SIZES = [4, 6]

  validates :size, inclusion: { in: SIZES }

  OUTCOMES = [-1 , 0 , 1]

  validates :outcome, inclusion: { in: OUTCOMES }

private
  def set_options
    active_game = Game.find_by(active: true)
    options = Tool.find_by(name: "clocks").game_tools.find_by(game_id: active_game&.id)&.options
    if options.present?
      SIZES.replace(options["size"].map { |s| s["size"] })
    end
  end

  def status_less_than_or_equal_to_size
    if status.present? && size.present? && status > size
      errors.add(:status, "must be less than or equal to size")
    end
  end

end
