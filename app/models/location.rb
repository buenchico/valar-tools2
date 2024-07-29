class Location < ApplicationRecord
  has_many :games
  belongs_to :family, optional: true
  belongs_to :region, class_name: "Location", optional: true, foreign_key: "region_id"
  has_many :sublocations, class_name: "Location", foreign_key: "region_id"
  has_many :armies, foreign_key: 'location_id'

  validates :name_en, presence: true, if: -> { name_es.blank? }
  validates :name_es, presence: true, if: -> { name_en.blank? }
  validates :priority, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: -100, less_than_or_equal_to: 100 }

  def name
    if self.name_es.nil?
      self.name_en
    else
      self.name_es
    end
  end

  def render
    render = nil

    if self.line.present?
      render = "polyline"
    end

    if self.polygon.present?
      render = "polygon"
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
end
