class MapController < ApplicationController
  before_action :set_tool
  before_action :set_options

  def index
    @locations = active_game.locations.where(visible: true)
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    @location_types = Tool.find_by(name: "locations").game_tools.find_by(game_id: active_game&.id)&.options["types"]
    if @options.nil?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar el mapa'
    end
  end
end
