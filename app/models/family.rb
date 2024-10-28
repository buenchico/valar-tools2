class Family < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :branch, :members]

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

  def hp(status)
    set_army_options if self.hp_step.nil?
    (self.armies.where(status: status).sum(:hp) / self.hp_step)
  end

  def hp_start(type)
    set_army_options if self.hp_step.nil?

    if type == 'all'
      (self.armies.sum(:hp_start) / self.hp_step)
    else
      (self.armies.where(army_type: type).sum(:hp_start) / self.hp_step)
    end
  end
end
