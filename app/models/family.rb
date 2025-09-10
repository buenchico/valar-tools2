class Family < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :branch, :members, :search]

  belongs_to :game
  belongs_to :faction, optional: true
  has_many :locations
  has_many :clocks, dependent: :nullify
  belongs_to :lord, class_name: 'Family', foreign_key: 'lord_id', optional: true
  has_many :vassals, class_name: 'Family', foreign_key: 'lord_id'
  has_many :units, foreign_key: 'family_id'

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

  def set_army_options
  end

  def men
    self.units&.sum(&:men) || 0
  end

  def men_start
    self.units&.sum(&:men_start) || 0
  end

  def men_death
    self.units&.sum(&:men_death) || 0
  end

  def composition
    self.units
      .group_by(&:unit_type)
      .sort_by { |unit_type, _| unit_type }
      .to_h
      .transform_values do |units|
        {
          count: units.sum(&:count),
          count_death: units.sum(&:count_death),
          count_start: units.sum(&:count_start),
          icon: units.first.icon,
          colour: units.first.colour,
          title: units.first.simple_title
        }
      end
  end

private
  def update_associated_locations
    locations.find_each(&:update_pg_search_document)
  end
end
