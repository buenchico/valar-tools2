class ToolsController < ApplicationController
  before_action :set_game, only: [:edit, :update, :destroy]

  def new
    @tool = Tool.new
  end

  # GET /tool/1/edit
  def edit
    @tools = Tool.all.order(:sort).order(:id)
  end

  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to settings_url, success: 'Partida creada correctamente.' }
      else
        format.html {  redirect_to settings_url, danger: @game.errors  }
      end
    end
  end

  # POST /game/1/edit
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to settings_url, success: 'Partida configurada correctamente.' }
      else
        format.html {  redirect_to settings_url, danger: @game.errors  }
      end
    end
  end

  def destroy
  end

private
  def set_tool
    @tool = Tool.find(params[:id])
  end

  def tool_params
      params.require(:tool).permit(:name, :title, :short_title, :icon_url, {options: []}, :role, :sort, :active, game_ids: [])
  end
end
