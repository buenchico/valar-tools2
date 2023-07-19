class TravelController < ApplicationController
  before_action :set_tool, only: [:index]

  def index
  end

  def calculate
    #get data from the form
    @from = params[:from] != "" ? params[:from] : "Origen"
    @to = params[:to] != "" ? params[:to] : "Destino"
    @size = params[:size].to_i
    @army_type = params[:army_type]

    @step = params[:step].nil? ? 0 : params[:step].to_unsafe_h

    #base speed
      @base_land = 10
      @base_sea = 4    

    puts "//////////"
    puts @step
    puts "//////////"

    respond_to :js
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game.id).options
    if @options.nil?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la calculadora de rutas'
    end
  end
end
