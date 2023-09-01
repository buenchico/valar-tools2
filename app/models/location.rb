class Location < ApplicationRecord
  has_many :games
  belongs_to :family, optional: true
  belongs_to :region, class_name: "Location", optional: true, foreign_key: "region_id"
  has_many :sublocations, class_name: "Location", foreign_key: "region_id"  

  validates :name_en, presence: true, if: -> { name_es.blank? }
  validates :name_es, presence: true, if: -> { name_en.blank? }

  # Validation to ensure that a location with location_type "region" cannot have a region
  validate :region_cannot_have_region, if: -> { location_type == "region" }

  def name
    if self.name_es.nil?
      self.name_en
    else
      self.name_es
    end
  end
end
