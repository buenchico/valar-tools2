class GameOptionsService
  def self.fetch
    @cache ||= load_options
  end

  def self.load_options
    active_game_id = Game.find_by(active: true)&.id
    return {} unless active_game_id

    armies_tool = Tool.find_by(name: "armies")
    travel_tool = Tool.find_by(name: "travel")

    {
      armies: armies_tool&.game_tools&.find_by(game_id: active_game_id)&.options || {},
      travel: travel_tool&.game_tools&.find_by(game_id: active_game_id)&.options&.fetch("speed", [])
    }
  end

  def self.clear!
    @cache = nil
  end
end
