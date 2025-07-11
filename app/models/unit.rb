class Unit < ApplicationRecord
  belongs_to :army
  before_create :set_men_start

private
  # Method to set hp_start to the value of hp
  def set_men_start
    self.men_start = self.men
  end
end
