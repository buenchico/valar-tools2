class User < ApplicationRecord
  belongs_to :faction
  has_many :battles

  validates_uniqueness_of :player

  before_create :generate_token
  before_update :prevent_updates_to_system_user

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

  def prevent_updates_to_system_user
    if name == "admin"
      errors.add(:base, "Superuser cannot be modified")
      throw(:abort)
    end
  end
end
