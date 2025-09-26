class GameTool < ApplicationRecord
  belongs_to :tool
  belongs_to :game
  # validate :options_cannot_be_changed_if_game_is_active, if: :options_changed?

  after_commit :invalidate_game_options_cache, on: [:update]

private
  def invalidate_game_options_cache
    if tool.name.in?(["armies", "travel"])
      GameOptionsService.clear!
    end
  end

  def options_cannot_be_changed_if_game_is_active
    if self.game.active
      errors.add(:options, I18n.t('activerecord.errors.models.game_tool.attributes.options.options_cannot_be_changed_if_game_is_active', game_name: self.game.title))
    end
  end
end
