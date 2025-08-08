class Unit < ApplicationRecord
  belongs_to :army
  before_create :set_count_start

private
  # Method to set hp_start to the value of hp
  def set_count_start
    self.count_start = self.count
  end
end
