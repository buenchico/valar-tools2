class Unit < ApplicationRecord
  belongs_to :army
  before_create :set_count_start

  validates :count, presence: true
  validates :unit_type, presence: true
  validates :modifier, presence: true

  def strength
    set_options if @option_armies.nil?

    unit_strength = @units.fetch(self.unit_type, {}).fetch("str", 0)

    self.count.to_i * unit_strength.to_i * (self.modifier / 100.0) * @status.fetch(self.army.status, {}).fetch("str", 0) * @scale
  end

  def hp
    set_options if @option_armies.nil?

    unit_hp = @units.fetch(self.unit_type, {}).fetch("hp", 0)

    (self.count.to_i * unit_hp.to_i * @status.fetch(self.army.status, {}).fetch("hp", 0)).to_i
  end

  def men
    set_options if @option_armies.nil?

    unit_men = @units.fetch(self.unit_type, {}).fetch("men", 0)

    self.count.to_i * unit_men * @status.fetch(self.army.status, {}).fetch("men", 0)
  end

  def men_start
    set_options if @option_armies.nil?

    unit_men = @units.fetch(self.unit_type, {}).fetch("men", 0)

    self.count_start.to_i * unit_men
  end

  def name
    set_options if @option_armies.nil?
    name = (@units.fetch(self.unit_type, {}).fetch("name", "")).pluralize(self.count)
    if self.modifier != 100
      name += (" v" + (self.modifier / 100.0).to_s)
    end
    return name
  end

private
  # Method to set hp_start to the value of hp
  def set_count_start
    self.count_start = self.count
  end

  def set_options
    active_game = Game.find_by(active: true)
    @option_armies = Tool.find_by(name: "armies").game_tools.find_by(game_id: active_game&.id)&.options

    @units = @option_armies["units"]
    @status = @option_armies["status"]
    @scale = @option_armies["general"]["scale"]
  end
end
