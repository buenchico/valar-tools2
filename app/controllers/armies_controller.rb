class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy, :show]
  before_action :set_options
  before_action :set_regions, only: [:new, :edit, :edit_multiple]
  before_action :set_factions, only: [:index, :edit, :edit_multiple, :new]
  before_action :set_filters, only: [:index]

  def index
    @faction = Faction.find_by(id: params[:faction_id])
    @reserve = Army.where(status: "active").where(visible: true)
    @dead = Army.where(status: "active").where(visible: true)
    @raised = Army.where(status: "active").where(visible: true)

    if @current_user&.is_master?
      if @faction
        @armies = @faction.armies.where(visible: true).order(:id)
      else
        @faction = @current_user.faction
        @armies = nil
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

  def edit_notes
  end

  def create
    @army = Army.new(army_params)

    respond_to do |format|
      if @army.save
        flash.now[:success] = t('messages.success.create', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @army.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: 'el ejército', method: 'create' } }
      end
    end
  end

  def update
    @inline = inline_param # Set the inline variable based on the parameter
    original_title =  @army.name

    respond_to do |format|
      if @army.update(army_params)
        if @inline == true
          @toast = t('messages.success.update', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        else
          flash.now[:success] = t('messages.success.update', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        end
        format.js
      else
        flash.now[:danger] = @army.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: original_title + " (id: " + @army.id.to_s + ")", method: 'update' } }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @army.destroy
        flash.now[:danger] = t('messages.success.destroy', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @army.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: @army.name.strip + " (id: " + @army.id.to_s + ")", method: 'delete' } }
      end
    end
  end

  def get_armies
    origin = URI(request.referer).path.split('/')[1]

    @active_factions = JSON.parse(params[:active_factions])
    @active_visibility = JSON.parse(params[:active_visibility])

    master = Faction.find_by(name: 'master')

    if @active_factions.include?(master.id.to_s)
      @armies = Army.all.where(visible: @active_visibility)
    else
      @armies = Army.joins(:factions).where(visible: @active_visibility).where(factions: { id: @active_factions })
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

  def set_army
    @army = Army.find(params[:id])
  end

  def set_factions
    @factions = Faction.where.not(name: ['admin','player']).where(active: true).order(:id)
  end

  def set_filters
    @filter = [ t('activerecord.attributes.army.selected'), t('activerecord.attributes.army.name'), t('activerecord.attributes.army.status'), t('activerecord.attributes.army.traits'), t('activerecord.attributes.army.position'), t('activerecord.attributes.army.group') ]
    if @current_user&.is_master?
        @filter << t('activerecord.attributes.army.visible')
    end
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

  # Use a separate method to handle the `inline` parameter for logic purposes
  def inline_param
    params.dig(:army, :inline) == "true"
  end
end
