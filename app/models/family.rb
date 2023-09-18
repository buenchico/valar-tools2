class Family < ApplicationRecord
  belongs_to :game
  belongs_to :faction, optional: true
  has_many :locations
  belongs_to :lord, class_name: 'Family', foreign_key: 'lord_id', optional: true
  has_many :vassals, class_name: 'Family', foreign_key: 'lord_id'
  has_many :armies, foreign_key: 'family_id'

  validates :name, presence: true

  def title
    if (self.branch.nil? || self.branch.empty?)
      self.name
    else
      self.name + " (" + self.branch + ")"
    end
  end

  def loyalties
    @options = $options_families

    # Create an array of the loyalty values, considering only the first loyalty_count values
    loyalty_values = []

    (1..@options["loyalties"].length).each do |i|
      loyalty_values << self.send("loyalty_#{i}")  # Use send to dynamically access loyalty attributes
    end

    loyalties = loyalty_values.map! { |value| value.nil? ? 0 : value }
    return loyalties
  end
end
