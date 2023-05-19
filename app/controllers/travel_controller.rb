class TravelController < ApplicationController
  before_action :set_tool, only: [:index]

  def index
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game.id).options
    if @options.nil?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la calculadora de rutas'
    end
  end
end
