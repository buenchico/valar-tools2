class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy, :show]
  before_action :set_options
  before_action :set_regions, only: [:new, :edit, :edit_multiple]
  before_action :set_factions, only: [:index, :edit, :edit_multiple, :new]


  def index
    @faction = Faction.find_by(id: params[:faction_id])
    if @current_user&.is_master?
      if @faction
        @armies = @faction.armies.where(visible: true).order(:id)
      else
        @faction = @current_user.faction
        @armies = Army.all
      end
    else
      @faction = @current_user.faction
      @armies = @faction.armies.where(visible: true).order(:id)
    end
  end

  def new
    @army = Army.new
    @army.units.build # builds one unit field by default
  end

  def edit
  end

  def create
    @army = Army.new(army_params)

    respond_to do |format|
      if @army.save
        flash.now[:success] = t('messages.success.update', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @army.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: 'el ejército', method: 'create' } }
      end
    end
  end

  def update
    respond_to do |format|
      if @army.update(army_params)
        flash.now[:success] = t('messages.success.update', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @army.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: original_title + " (id: " + @army.id.to_s + ")", method: 'update' } }
      end
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

  def set_army
    @army = Army.find(params[:id])
  end

  def set_factions
    @factions = Faction.where.not(name: ['admin','player']).where(active: true).order(:id)
  end

  def army_params
    params.require(:army).permit(
      :name, :status, :position, :group, :location_id, :family_id, :confirm,
      :visible, :notes, :board, faction_ids: [], tags: [],
      units_attributes: [:id, :unit_type, :count, :modifier, :_destroy]
    ).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
      whitelisted[:board] = nil if whitelisted.key?(:board) && whitelisted[:board].blank?
    end
  end
end
