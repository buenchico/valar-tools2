class MapController < ApplicationController
  before_action :set_tool
  before_action :set_options
  before_action :set_locations_list

  def index
  end

  def show
    @location = Location.find(params[:id])
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    @location_types = Tool.find_by(name: "locations").game_tools.find_by(game_id: active_game&.id)&.options["types"]
    if @options.nil?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar el mapa'
    end
  end

  def set_locations_list
    @locations = active_game.locations.where(visible: true)
  end
end
