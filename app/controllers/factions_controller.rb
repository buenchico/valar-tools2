class FactionsController < ApplicationController
  before_action :check_master
  before_action :set_tool
  before_action :set_faction, only: [:edit, :update]

  def index
    @factions = Faction.all.order(:id)
  end

  def edit
    @games = Game.all.order(:id)
  end

  def update
    respond_to do |format|
      if @faction.update(faction_params)
        format.html { redirect_to factions_url, success: 'Facción editada correctamente.' }
      else
        format.html {  redirect_to factions_url, danger: @faction.errors  }
      end
    end
  end

  private
    def set_faction
      @faction = Faction.find(params[:id])
    end

    def faction_params
      params.require(:faction).permit(:name, :long_name, :discourse_id, :reputation, :active, :flair_url, game_ids: [])
    end
end
