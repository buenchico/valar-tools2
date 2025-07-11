class Family < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :branch, :members, :search]

  belongs_to :game
  belongs_to :faction, optional: true
  has_many :locations
  has_many :clocks, dependent: :nullify
  belongs_to :lord, class_name: 'Family', foreign_key: 'lord_id', optional: true
  has_many :vassals, class_name: 'Family', foreign_key: 'lord_id'
  has_many :armies, foreign_key: 'family_id'

  validates :name, presence: true

  after_save :update_associated_locations

  def title
    if (self.branch.nil? || self.branch.empty?)
      self.name
    else
      self.name + " (" + self.branch + ")"
    end
  end

  def search
    self.locations&.pluck(:name_es, :name_en).join(", ")
  end

  attr_accessor :hp_step

  def set_army_options
    active_game = Game.find_by(active: true)
    if Tool.find_by(name: "armies").is_active?
      self.hp_step = Tool.find_by(name: "armies").game_tools.find_by(game_id: active_game&.id)&.options.dig("hp", "step")
    end
  end

  def hp(status)
    set_army_options if self.hp_step.nil?
    if Tool.find_by(name: "armies").is_active?
      (self.armies.where(status: status).sum(:hp) / self.hp_step)
    end
  end

  def hp_start(type)
    set_army_options if self.hp_step.nil?

    if Tool.find_by(name: "armies").is_active?
      if type == 'all'
        (self.armies.sum(:hp_start) / self.hp_step)
      else
        (self.armies.where(army_type: type).sum(:hp_start) / self.hp_step)
      end
    end
  end

private
  def update_associated_locations
    locations.find_each(&:update_pg_search_document)
  end
end
