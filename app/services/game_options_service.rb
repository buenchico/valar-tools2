class GameOptionsService
  def self.fetch
    @cache ||= load_options
  end

  def self.load_options
    active_game_id = Game.find_by(active: true)&.id
    return {} unless active_game_id

    armies_tool = Tool.find_by(name: "armies")
    travel_tool = Tool.find_by(name: "travel")
    locations_tool = Tool.find_by(name: "locations")
    clocks_tool = Tool.find_by(name: "clocks")
    families_tool = Tool.find_by(name: "families")
    missions_tool = Tool.find_by(name: "missions")
    map_tool = Tool.find_by(name: "map")

    {
      armies: armies_tool&.game_tools&.find_by(game_id: active_game_id)&.options || {},
      travel: travel_tool&.game_tools&.find_by(game_id: active_game_id)&.options || {},
      locations: locations_tool&.game_tools&.find_by(game_id: active_game_id)&.options || {},
      clocks: clocks_tool&.game_tools&.find_by(game_id: active_game_id)&.options || {},
      fammilies: families_tool&.game_tools&.find_by(game_id: active_game_id)&.options || {},
      missions: missions_tool&.game_tools&.find_by(game_id: active_game_id)&.options || {},
      map: map_tool&.game_tools&.find_by(game_id: active_game_id)&.options || {}
    }
  end

  def self.clear!
    @cache = nil
  end
end
