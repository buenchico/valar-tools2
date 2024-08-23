class Family < ApplicationRecord
  belongs_to :game
  belongs_to :faction, optional: true
  has_many :locations
  has_many :clocks, dependent: :nullify
  belongs_to :lord, class_name: 'Family', foreign_key: 'lord_id', optional: true
  has_many :vassals, class_name: 'Family', foreign_key: 'lord_id'
  has_many :armies, foreign_key: 'family_id'

  validates :name, presence: true

  def title
    if (self.branch.nil? || self.branch.empty?)
      self.name
    else
      self.name + " (" + self.branch + ")"
    end
  end

  attr_accessor :hp_step

  def set_army_options
    active_game = Game.find_by(active: true)
    self.hp_step = (Tool.find_by(name: "armies").game_tools.find_by(game_id: active_game&.id)&.options.dig("hp", "step") || 10)
  end

  def hp_raised
    set_army_options if hp_step.nil?
    (armies.where(status: 'raised').sum(:hp) / hp_step)
  end

  def hp_inactive
    set_army_options if hp_step.nil?
    (armies.where(status: 'inactive').sum(:hp_start) / hp_step)
  end

  def hp_start_no_bleed
    set_army_options if hp_step.nil?
    (armies.where.not(army_type: 'bleed').sum(:hp_start) / hp_step)
  end

  def hp_start_total
    set_army_options if hp_step.nil?
    (armies.sum(:hp_start) / hp_step)
  end
end
