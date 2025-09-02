class UnitsController < ApplicationController
  before_action :set_options
  before_action :set_factions, only: [:new, :edit]
  before_action :set_regions, only: [:new, :edit]
  before_action :set_unit, only: [:edit, :update, :destroy]
  before_action :check_master, only: [:new, :edit, :create, :destroy, :update]

  def new
    @unit = Unit.new
  end

  def edit
  end

  def create
    @unit = Unit.new(unit_params)

    respond_to do |format|
      if @unit.save
        flash.now[:success] = t('messages.success.create', thing: @unit.name.strip + " (id: " + @unit.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @unit.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: 'el ejército', method: 'create' } }
      end
    end
  end

  def update
    respond_to do |format|
      if @unit.update(unit_params)
        flash.now[:success] = t('messages.success.update', thing: @unit.name.strip + " (id: " + @unit.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @unit.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: @unit.name.strip + " (id: " + @unit.id.to_s + ")", method: 'update' } }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @unit.destroy
        flash.now[:danger] = t('messages.success.destroy', thing: @unit.name.strip + " (id: " + @unit.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @unit.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: @unit.name.strip + " (id: " + @unit.id.to_s + ")", method: 'delete' } }
      end
    end
  end

private
  def set_unit
    @unit = Unit.find(params[:id])
  end

  def set_options
    tool = Tool.find_by(name: "armies")
    @options_armies = get_options(tool)
    if @options_armies.blank?
      redirect_to settings_url, warning: t('activerecord.errors.messages.options_not_ready', tool_name: @tool.title)
    else
      set_options_armies
    end
  end

  def unit_params
    params.require(:unit).permit(
      :name, :location_id, :family_id,
      :count, :count_start, :count_death, :strength_mod, :strength_indirect_mod, :hp_mod,
      :visible, :unit_type, faction_ids: [], tags: []
    ).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
    end
  end
end
