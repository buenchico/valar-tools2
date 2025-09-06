class Army < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :position, :notes, :search]

  has_many :units, dependent: :nullify
  accepts_nested_attributes_for :units, allow_destroy: true
  has_and_belongs_to_many :factions

  before_validation :ensure_minimum_xp
  before_validation :ensure_minimum_morale

  validate :must_have_at_least_one_unit
  validates :name, presence: true, uniqueness: true
  validates :xp, numericality: { greater_than_or_equal_to: 50 }
  validates :morale, numericality: { greater_than_or_equal_to: 0 }

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
    self.units.includes(:family).map(&:family).compact.uniq.sort_by(&:title)
  end

  def locations
    self.units.includes(:location).map(&:location).compact.uniq.sort_by(&:name)
  end

  def factions
    self.units.includes(:factions).flat_map(&:factions).uniq.sort_by(&:name)
  end

  def composition
    self.units
      .group_by(&:unit_type)
      .sort_by { |unit_type, _| unit_type }
      .to_h
      .transform_values do |units|
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

  def icon
    units&.first&.army_icon
  end

  def colour
    units&.first&.colour
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
      errors.add(:units, I18n.t('activerecord.errors.models.army.attributes.units.must_include_one'))
    end
  end

  def ensure_minimum_xp
    self.xp = 50 if xp.present? && xp < 50
  end

  def ensure_minimum_morale
    self.morale = 0 if morale.present? && morale < 0
  end
end
