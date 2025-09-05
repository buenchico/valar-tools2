class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy, :show, :delete]
  before_action :set_options
  before_action :set_factions, only: [:index, :new, :edit]


  def index
    @faction = Faction.find_by(id: params[:faction_id])

    if @current_user&.is_master?
      if @faction
        armies, units = get_armies([@faction.id], ["true"])
        @armies = armies.sort_by(&:army_type)
        @units = units.where(army: nil).sort_by(&:army_type).sort_by(&:army_type)
      else
        @armies = nil
        @units = nil
      end
    else
      @faction = @current_user.faction
      armies, units = get_armies([@faction.id], ["true"])
      @armies = armies.sort_by(&:army_type)
      @units = units.where(army: nil).sort_by(&:army_type).sort_by(&:army_type)
    end
  end

  def show_armies
    active_factions = JSON.parse(params[:active_factions])
    active_visibility = JSON.parse(params[:active_visibility])

    @armies, units = get_armies(active_factions, active_visibility)
    @units = units.where(army: nil)
  end

  def delete
  end

  def create
    @army = Army.new(army_params)

    if params[:source] == 'units'
      @unit_ids = params["unit_ids"]
      army_params = self.army_params # This is needed to be able to redefine army_params later
      army_params = army_params.merge(unit_ids: @unit_ids)
    end

    respond_to do |format|
      if params[:confirm].nil? || params[:confirm] == 'VALIDATE'
        if @army.update(army_params)
          flash.now[:success] = t('messages.success.create', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
          format.js
        else
          flash.now[:danger] = @army.errors.to_hash
          format.js { render 'layouts/error', locals: { thing: @army.name.strip + " (id: " + @army.id.to_s + ")", method: 'create' } }
        end
      else
        flash.now[:danger] = t('messages.validation')
        format.js { render 'layouts/error' }
      end
    end
  end

  def update
    if params[:source] == 'units'
      @new_unit_ids = params["unit_ids"]
      old_unit_ids = @army.unit_ids
      unit_ids = @new_unit_ids.concat(old_unit_ids)
      army_params = self.army_params # This is needed to be able to redefine army_params later
      army_params = army_params.merge(unit_ids: unit_ids)
    end

    respond_to do |format|
      if params[:confirm].nil? || params[:confirm] == 'VALIDATE'
        if @army.update(army_params)
          flash.now[:success] = t('messages.success.update', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
          format.js
        else
          flash.now[:danger] = @unit.errors.to_hash
          format.js { render 'layouts/error', locals: { thing: @army.name.strip + " (id: " + @army.id.to_s + ")", method: 'update' } }
        end
      else
        flash.now[:danger] = t('messages.validation')
        format.js { render 'layouts/error' }
      end
    end
  end

  def destroy
    respond_to do |format|
      if params[:confirm].nil? || params[:confirm] == 'DELETE'
        if @army.destroy
          flash.now[:danger] = t('messages.success.destroy', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
          format.js
        else
          flash.now[:danger] = @army.errors.to_hash
          format.js { render 'layouts/error', locals: { thing: @army.name.strip + " (id: " + @army.id.to_s + ")", method: 'delete' } }
        end
      else
        flash.now[:danger] = t('messages.validation')
	      format.js { render 'layouts/error' }
      end
    end
  end

private
  def set_army
    @army = Army.find(params[:id])
  end

  def set_options
    @options_armies = get_options(@tool)
    if @options_armies.blank?
      redirect_to settings_url, warning: t('activerecord.errors.messages.options_not_ready', tool_name: @tool.title)
    else
      set_options_armies
    end
  end

  def get_armies(factions, visibility)
    master = Faction.find_by(name: 'master')
    if factions.count == 1
      faction = Faction.find_by(id: factions)
    end

    if factions.include?(master.id.to_s)
      armies = Army.all.where(visible: visibility)
      units = Unit.all.where(visible: visibility)
    else
      armies = Army
        .joins(units: :factions)
        .where(visible: visibility)
        .where(factions: { id: factions })
        .distinct
      units = Unit.joins(:factions).where(visible: visibility).where(factions: { id: factions })
    end

    return [armies, units]
  end

  def army_params
    params.require(:army).permit(
      :name, :status, :position,
      :visible, :notes, :xp, :morale, tags: [],
      units_attributes: [:id, :_destroy]
    ).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
    end
  end
end
