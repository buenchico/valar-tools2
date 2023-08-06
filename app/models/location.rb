class Location < ApplicationRecord
  has_many :games
  belongs_to :family, optional: true

  validates :name_en, presence: true

  def name
    if self.name_es.nil?
      self.name_en
    else
      self.name_es
    end
  end
end
