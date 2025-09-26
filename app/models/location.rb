class Location < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name_es, :name_en, :description, :search]

  belongs_to :game
  belongs_to :family, optional: true
  belongs_to :region, class_name: "Location", optional: true, foreign_key: "region_id"
  has_many :sublocations, class_name: "Location", foreign_key: "region_id"
  has_many :armies, foreign_key: 'location_id'

  validates :name_en, presence: true, if: -> { name_es.blank? }
  validates :name_es, presence: true, if: -> { name_en.blank? }
  validates :priority, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: -100, less_than_or_equal_to: 100 }
  validate :population_only_for_types

  before_validation :set_options
  before_validation :clear_population_if_disallowed

  after_initialize :set_options

  def name
    if self.name_es.nil?
      self.name_en
    else
      self.name_es
    end
  end

  def title
    self.name
  end

  def search
    self.family&.name
  end

  def middle_point
    if self.render == "point"
      middle_point = [self.x, self.y]
    elsif self.render == "multipoint"
      middle_point = [self.x[0], self.y[0]]
    elsif self.render == "polyline"
      points = JSON.parse(self.line).flatten
      length = (points.length / 2)

      mid_x = (points.each_index.select { |i| i.odd? }.sum { |i| points[i] } / length)
      mid_y = (points.each_index.select { |i| i.even? }.sum { |i| points[i] } / length)

      middle_point = [mid_x, mid_y]
    elsif self.render == "polygon"
      points = JSON.parse(self.polygon).flatten
      length = (points.length / 2)

      mid_x = (points.each_index.select { |i| i.odd? }.sum { |i| points[i] } / length)
      mid_y = (points.each_index.select { |i| i.even? }.sum { |i| points[i] } / length)

      middle_point = [mid_x, mid_y]
    end
  end

  def render
    render = nil

    if self.line.present?
      begin
        parsed = JSON.parse(self.line)
        if parsed.is_a?(Array)
          render = "polyline"
        end
      rescue JSON::ParserError
        nil
      end
    end

    if self.polygon.present?
      begin
        parsed = JSON.parse(self.polygon)
        if parsed.is_a?(Array)
          render = "polygon"
        end
      rescue JSON::ParserError
        nil
      end
    end

    if self.x.present? && self.y.present?
      if self.x.is_a?(Array) && self.y.is_a?(Array)
        render = "multipoint"
      end

      render = "point"
    end

    return render
  end

  scope :search_by_name, ->(query) do
    where("lower(name_en) LIKE :query OR lower(name_es) LIKE :query", query: "%#{query.downcase}%")
  end

private
  def population_only_for_types
    if !(@population_types.include?(location_type) && (population.present? || population_start.present?))
      errors.add(:population, :only_in_selected_types, types: @population_types.join(", "))
    end
  end

  def clear_population_if_disallowed
    unless @population_types.include?(location_type)
      self.population = nil
      self.population_start = nil
    end
  end

  def set_options
    options = GameOptionsService.fetch
    @options_locations = options[:locations]
    @population_types = @options_locations.fetch("population", {}).fetch("types_with_population", ["region"])
  end
end
