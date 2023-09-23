class Mission < ApplicationRecord
  belongs_to :faction
  belongs_to :user, optional: true
end
