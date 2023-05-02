class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :update, :destroy]


  def index
    @armies = Army.all
  end

  def edit
  end

private
  def set_army
    @army = Army.find(params[:id])
  end

  def army_params
      params.require(:army).permit(:name, :title, :short_title, :icon_url, :options, :role, :sort, :active, game_ids: [])
  end
end
