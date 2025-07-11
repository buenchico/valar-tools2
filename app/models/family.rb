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

  def set_army_options
  end

  def hp(status)
  end

  def hp_start(type)
  end

private
  def update_associated_locations
    locations.find_each(&:update_pg_search_document)
  end
end
