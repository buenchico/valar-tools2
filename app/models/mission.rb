class Mission < ApplicationRecord
  belongs_to :faction
  belongs_to :game
  belongs_to :user, optional: true

  def url
    'https://www.valar.es/t/' + self.discourse_id.to_s
  end
end
