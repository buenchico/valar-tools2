class Faction < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:name, :long_name, :title, :description, :tokens, :pov]

  has_many :users
  has_and_belongs_to_many :armies
  has_and_belongs_to_many :games
  has_many :families
  validates :name, presence: true, uniqueness: true, format: { without: /\s/ }
  validates :long_name, presence: true, uniqueness: true
  accepts_nested_attributes_for :games
end
