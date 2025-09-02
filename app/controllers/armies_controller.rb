class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy, :show]
  before_action :set_options

def index
  @faction = Faction.find_by(id: params[:faction_id])

  if @current_user&.is_master?
    if @faction
      @armies = @faction.armies.where(visible: true).order(:id)
      @units = @faction.units.where(visible: true, army_id: nil).order(:id)
    else
      @armies = nil
      @units = Unit.all
    end
  else
    @faction = @current_user.faction
    @armies = @faction.armies.where(visible: true).order(:id)
    @units = @faction.units.where(visible: true, army_id: nil).order(:id)
  end
end

private
  def set_options
    @options_armies = get_options(@tool)
    if @options_armies.blank?
      redirect_to settings_url, warning: t('activerecord.errors.messages.options_not_ready', tool_name: @tool.title)
    else
      set_options_armies
    end
  end
end
