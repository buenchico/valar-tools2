class GamesController < ApplicationController
  before_action :set_game, only: [:edit, :update, :destroy, :set_active_game]
  before_action :check_admin

  def new
    @game = Game.new
    @tools = Tool.all.order(:sort).order(:id)
  end

  # GET /game/1/edit
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
    respond_to do |format|
      if @game.destroy
        format.html { redirect_to settings_url, success: 'Partida eliminada correctamente.' }
      else
        format.html {  redirect_to settings_url, danger: @game.errors  }
      end
    end
  end

  def set_active_game
    respond_to do |format|
      if Game.update_all(active: false) && @game.update(active: true)
        format.html { redirect_to settings_url, success: 'Partida inicializada correctamente.' }
      else
        format.html { redirect_to settings_url, danger: @game.errors }
      end
    end
  end

  def unset_active_game
    respond_to do |format|
      if Game.update_all(active: false)
        format.html { redirect_to settings_url, success: 'Partida terminada correctamente.' }
      else
        format.html { redirect_to settings_url, danger: @game.errors }
      end
    end
  end

private
  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:name, :prefix, :title, :icon_url, game_tools_attributes: [:id, :active, :options])
          .tap do |whitelisted|
      if whitelisted[:game_tools_attributes].present?
        whitelisted[:game_tools_attributes].each do |index, tool_params|
          if tool_params[:options].present?
            whitelisted[:game_tools_attributes][index][:options] = JSON.parse(tool_params[:options])
          end
        end
      end
    end
  end
end
