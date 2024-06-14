class Clock < ApplicationRecord
  belongs_to :family, optional: true

  def display
    empty = self.size.to_i - self.status.to_i
    fill = self.status.to_i

    return [fill,empty]
  end
end
