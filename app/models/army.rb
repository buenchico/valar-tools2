class Army < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :position, :notes, :search]

  has_many :units, dependent: :destroy
  accepts_nested_attributes_for :units, allow_destroy: true
  has_and_belongs_to_many :factions

  validate :must_have_at_least_one_unit

  def search
   nil
  end

  def strength
    self.strength_calc[:total]
  end

  def strength_calc
    set_options if @options_armies.nil?

    units = self.units.sum(&:strength)

    mult = ((self.xp.to_f / 100.0) * (self.morale.to_f / 100.0)).round(2)

    tags = 0

    total = units * mult

    str = { "total": total.round(2), "subtotal": units.round(2), "mult": mult, "tags": tags }

    return str
  end

  def strength_indirect
    self.strength_calc[:total]
  end

  def strength_indirect_calc
    set_options if @options_armies.nil?

    units = self.units.sum(&:strength_indirect)

    mult = (self.xp.to_f / 100.0) * (self.morale.to_f / 100.0).round(2)

    tags = 0

    total = units * mult

    str = { "total": total.round(2), "subtotal": units.round(2), "mult": mult, "tags": tags }

    return str
  end

  def men
    units.sum(&:men).to_i
  end

  def men_start
    units.sum(&:men_start).to_i
  end

  def hp
    units.sum(&:hp).to_i
  end

  def hp_start
    units.sum(&:hp_start).to_i
  end

  def families
    self.units.includes(:family).map(&:family).compact.uniq
  end

  def factions
    self.units.includes(:factions).flat_map(&:factions).uniq
  end

  def composition
    self.units.group_by(&:unit_type).transform_values do |units|
    {
      count: units.sum(&:count),
      icon: units.first.icon,
      colour: units.first.colour,
      title: units.first.title
    }
    end
  end

  def unit_tags
    units.flat_map(&:tags).compact.uniq
  end

  def army_type
    units&.first&.army_type
  end

private
  def set_options
    active_game = Game.find_by(active: true)
    @options_armies = Tool.find_by(name: "armies").game_tools.find_by(game_id: active_game&.id)&.options

    @units = @options_armies["units"]
    @army_types = @options_armies["army_type"]&.sort_by { |_, v| v["sort"] }.to_h
    @status = @options_armies["status"]
    @army_scale = @options_armies["general"]["scale"]
  end

  def must_have_at_least_one_unit
    if units.empty? || units.all?(&:marked_for_destruction?)
      errors.add(:units, "must include at least one unit")
    end
  end
end
