class Unit < ApplicationRecord
  belongs_to :army
  before_create :set_troops_start

  validates :count, presence: true
  validates :unit_type, presence: true
  validates :modifier, presence: true

  def strength
    set_options if @options_armies.nil?

    unit_strength = @units.fetch(self.unit_type, {}).fetch("str", 0)

    ((self.troops.to_i * unit_strength.to_i * (self.modifier / 100.0)) / @army_scale).round(2)
  end

  def hp
    set_options if @options_armies.nil?

    unit_hp = @units.fetch(self.unit_type, {}).fetch("hp", 0)

    (self.troops.to_i * unit_hp.to_i).to_i
  end

  def hp_start
    set_options if @options_armies.nil?

    unit_hp = @units.fetch(self.unit_type, {}).fetch("hp", 0)

    (self.troops_start.to_i * unit_hp.to_i)
  end

  def men
    set_options if @options_armies.nil?

    unit_men = @units.fetch(self.unit_type, {}).fetch("men", 0)

    self.troops.to_i * unit_men
  end

  def men_start
    set_options if @options_armies.nil?

    unit_men = @units.fetch(self.unit_type, {}).fetch("men", 0)

    self.troops_start.to_i * unit_men
  end

  def name
    set_options if @options_armies.nil?
    name = (@units.fetch(self.unit_type, {}).fetch("name", "")).pluralize(self.count)
    if self.modifier != 100
      name += (" v" + (self.modifier / 100.0).to_s)
    end
    return name
  end

  def icon
    set_options if @options_armies.nil?
    icon = @units.fetch(self.unit_type, {}).fetch('icon', nil)
    return icon
  end

  def troops
    set_options if @options_armies.nil?

    status_mod = @status.fetch(self.army.status, {}).fetch("mod", 0)

    self.count.to_i * @status.fetch(self.army.status, {}).fetch("mod", 0)
  end

private
  def set_troops_start
    self.troops_start = self.count
  end

  def set_options
    active_game = Game.find_by(active: true)
    @options_armies = Tool.find_by(name: "armies").game_tools.find_by(game_id: active_game&.id)&.options

    @units = @options_armies["units"]
    @status = @options_armies["status"]
    @army_scale = @options_armies["general"]["scale"]
  end
end
