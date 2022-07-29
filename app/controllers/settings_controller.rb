class SettingsController < ApplicationController
  before_action :set_game, only: [:edit_game, :update_game, :destroy_game]


  def index
    @tool = Tool.find_by(name: controller_name)

    @games = Game.all.order(:id)
    @tools = Tool.all.order(:sort).order(:id)
  end

  # GET /game/1/edit
  def edit_game
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find_by(name: params[:name])
    end
end
