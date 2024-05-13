class Battle < ApplicationRecord
  belongs_to :user

  validates_uniqueness_of :name
  validates :date, presence: true
  validates :terrain, presence: true

end
