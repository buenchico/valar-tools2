class User < ApplicationRecord
  belongs_to :faction
  validates_uniqueness_of :player
  before_create :generate_token

  def generate_token
    begin
      self[:auth_token] = SecureRandom.urlsafe_base64
    end while User.exists?(:auth_token => self[:auth_token])
  end

  # Roles methodes
  def is_admin?
    self.faction.name == 'admin'
  end

  def is_master?
    self.faction.name == 'master' || self.faction.name == 'admin'
  end

  def is_active?
    self.faction.name != 'player'
  end
end
