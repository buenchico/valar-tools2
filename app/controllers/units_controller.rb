class UnitsController < ApplicationController
  before_action :set_options
  before_action :set_factions, only: [:new, :edit, :new_multiple]
  before_action :set_regions, only: [:new, :edit, :new_multiple]
  before_action :set_unit, only: [:edit, :update, :destroy, :delete]
  before_action :check_master, only: [:new, :edit, :create, :destroy, :delete]

  def new
    @unit = Unit.new
  end

  def new_multiple
    @units = [Unit.new]
  end

  def edit
  end

  def delete
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
      if params[:confirm].nil? || params[:confirm] == 'DELETE'
        if @unit.destroy
          flash.now[:danger] = t('messages.success.destroy', thing: @unit.name.strip + " (id: " + @unit.id.to_s + ")", count: 1)
          format.js
        else
          flash.now[:danger] = @unit.errors.to_hash
          format.js { render 'layouts/error', locals: { thing: @unit.name.strip + " (id: " + @unit.id.to_s + ")", method: 'delete' } }
        end
      else
        format.html { redirect_to armies_url, danger: t('messages.validation') }
      end
    end
  end

  def create_multiple
    faction_ids = params[:faction_ids]
    units = params[:units]

    created_units = []
    failed_units = []

    units.each do |unit_data|
      unit_params = {
        name: '',
        unit_type: unit_data[:unit_type],
        location_id: unit_data[:location_id],
        family_id: unit_data[:family_id],
        count: unit_data[:count],
        tags: unit_data[:tags].reject!(&:empty?)
      }

      unit = Unit.new(unit_params)

      unit.faction_ids = faction_ids if faction_ids.present?

      if unit.valid?
        created_units << unit
      else
        failed_units << { unit: unit, errors: unit.errors.full_messages }
      end
    end

    respond_to do |format|
      if params[:confirm] != 'VALIDATE'
        format.html { redirect_to armies_url, danger: t('messages.validation') }
      else
        if failed_units.any?
          flash.now[:danger] = t(
            'messages.multiple.error',
            model: Unit.model_name.human(count: created_units.count),
            failed: ("<br>" + failed_units.map { |u| "Unidad inválida: #{u[:errors].join(', ')}" }.join("<br>")).html_safe
          )
          format.js
        else
          Unit.transaction do
            created_units.each(&:save!)
          end

          flash[:success] = t('messages.multiple.success', model: Unit.model_name.human(:count => created_units.count), succeed: ("<br>" + created_units.pluck(:name).join("<br>")).html_safe)
          format.js
        end
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
