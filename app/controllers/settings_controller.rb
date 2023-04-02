class SettingsController < ApplicationController
  before_action :set_game, only: [:edit_game, :update_game, :destroy_game]


  def index
    @tool = Tool.find_by(name: controller_name)

    @games = Game.all.order(:id)
    @tools = Tool.all.order(:sort).order(:id)
  end

  # GET /game/1/edit
  def edit_game
    @tools = Tool.all.order(:sort).order(:id)
  end

  # POST /game/1/edit
  def update_game
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to settings_url, success: 'Partida configurada correctamente.' }
      else
        format.html {  redirect_to settings_url, danger: @game.errors  }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:name, :prefix, :title, :icon_url, tools_attributes: [:id, :name])
    end
end
