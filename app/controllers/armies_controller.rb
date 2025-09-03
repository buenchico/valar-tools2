class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy, :show]
  before_action :set_options
  before_action :set_factions, only: [:index, :new, :edit]


def index
  @faction = Faction.find_by(id: params[:faction_id])

  if @current_user&.is_master?
    if @faction
      @armies = @faction.armies.where(visible: true).order(:id)
      @units = @faction.units.where(visible: true, army_id: nil).order(:id)
    else
      @armies = nil
      @units = nil
    end
  else
    @faction = @current_user.faction
    @armies = @faction.armies.where(visible: true).order(:id)
    @units = @faction.units.where(visible: true, army_id: nil).order(:id)
  end
end

def get_armies
  origin = URI(request.referer).path.split('/')[1]

  @active_factions = JSON.parse(params[:active_factions])
  @active_visibility = JSON.parse(params[:active_visibility])

  @armies_all = Army.where(visible: true)

  master = Faction.find_by(name: 'master')

  if @active_factions.count == 1
    @faction = Faction.find_by(id: @active_factions)
  end

  if @active_factions.include?(master.id.to_s)
    @armies = Army.all.where(visible: @active_visibility)
    @units = Unit.all.where(visible: @active_visibility)
  else
    @armies = Army.joins(:factions).where(visible: @active_visibility).where(factions: { id: @active_factions })
    @units = Unit.joins(:factions).where(visible: @active_visibility).where(factions: { id: @active_factions })
  end

  respond_to do |format|
    format.js
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
