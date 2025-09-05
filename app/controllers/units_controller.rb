class UnitsController < ApplicationController
  before_action :set_options
  before_action :set_factions, only: [:new, :edit, :new_multiple, :edit_multiple]
  before_action :set_regions, only: [:new, :edit, :new_multiple]
  before_action :set_unit, only: [:edit, :update, :destroy, :delete]
  before_action :check_master, only: [:new, :edit, :delete, :edit_multiple, :create, :destroy, :delete, :update_multiple, :destroy_multiple]
  before_action :check_owner, only: [:edit, :edit_notes, :update]

  def new
    @unit = Unit.new
  end

  def new_multiple
    @units = [Unit.new]
  end

  def edit
  end

  def edit_multiple
    unit_ids = params[:unit_ids].split(',')
    @units = Unit.where(id: unit_ids).order(:name)
    @army_type = @units.map(&:army_type).uniq
    @armies = Army.includes(:units).select { |army| army.army_type == @army_type[0] }
    @army = Army.new
    @template = 'form_' + params[:button] + '_multiple'
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

    @created_units = []
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
        @created_units << unit
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
            model: Unit.model_name.human(count: @created_units.count),
            failed: ("<br>" + failed_units.map { |u| "Unidad inválida: #{u[:errors].join(', ')}" }.join("<br>")).html_safe,
            succeed: ("<br>" + @created_units&.map { |u| "Unidad exitosa: #{u.name}"}&.join("<br>")).html_safe
          )
          format.js
        else
          Unit.transaction do
            @created_units.each(&:save!)
          end

          flash[:success] = t('messages.multiple.success', model: Unit.model_name.human(:count => @created_units.count), succeed: ("<br>" + @created_units.pluck(:name).join("<br>")).html_safe)
          format.js
        end
      end
    end
  end

  def update_multiple
    @units = Unit.where(id: params[:unit_ids])

    unit_params = { change: {}, sum: {}, add: {}, remove: {} }

    unit_params[:change][:hp_mod] = params["unit"]["hp_change"] unless params["unit"]["hp_change"].empty?
    unit_params[:sum][:hp_mod] = params["unit"]["hp_sum"] unless params["unit"]["hp_sum"].empty?
    unit_params[:change][:strength_mod] = params["unit"]["strength_change"] unless params["unit"]["strength_change"].empty?
    unit_params[:sum][:strength_mod] = params["unit"]["strength_sum"] unless params["unit"]["strength_sum"].empty?
    unit_params[:change][:strength_indirect_mod] = params["unit"]["strength_indirect_change"] unless params["unit"]["strength_indirect_change"].empty?
    unit_params[:sum][:strength_indirect_mod] = params["unit"]["strength_indirect_sum"] unless params["unit"]["strength_indirect_sum"].empty?
    unit_params[:add][:tags] = params["unit"]["tags_add"].reject(&:empty?)
    unit_params[:remove][:tags] = params["unit"]["tags_remove"].reject(&:empty?)
    unit_params[:change][:visible] = params["unit"]["visible"] unless params["unit"]["visible"].empty?

    if params["unit"]["faction_ids"] == ["CLEAR"]
      unit_params[:change][:faction_ids] == []
    else
      unit_params[:change][:faction_ids] = params["unit"]["faction_ids"].reject(&:empty?)
    end

    @errors_units = []
    @updated_units = []

    respond_to do |format|
      if params[:unit][:confirm] == 'VALIDATE'
        if unit_params.values.map(&:values).flatten.compact.empty? # all values are empty
          format.html { redirect_to armies_url, success: t('messages.multiple.nothing') }
        else
          @units.each do |unit|
            unit_params[:sum].each do |key, value|
              if unit.respond_to?(key)
                old_value = unit[key]
                unit.send("#{key}=", (old_value += value))
              end
            end

            unit_params[:change].each do |key, value|
              if unit.respond_to?(key)
                unit.send("#{key}=", value)
              end
            end

            unit_params[:add].each do |key, value|
              if unit.respond_to?(key)
                puts key
                puts unit[key]
                old_value = unit[key]
                unit.send("#{key}=", (old_value + value))
              end
            end

            unit_params[:remove].each do |key, value|
              if unit.respond_to?(key)
                old_value = unit[key]
                unit.send("#{key}=", (old_value - value))
              end
            end

            if unit.save
              @updated_units << unit
            else
              @errors_units << (unit.name.to_s + " | " + unit.errors.full_messages.join(", "))
            end
          end

          if @errors_units.length == 0
            flash[:success] = t('messages.multiple.success', model: Unit.model_name.human(:count => @updated_units.length), succeed: ("<br>" + @updated_units.join("<br>")).html_safe)
            format.js
          else
            flash[:danger] = t('messages.multiple.error', model: Unit.model_name.human(:count => @errors_units.length), failed: ("<br>" + @errors_units.join("<br>") + "<br>").html_safe, succeed: ("<br>" + @updated_units.pluck(:name).join("<br>")).html_safe)
            format.js
          end
        end
      else
        format.html { redirect_to armies_url, danger: t('messages.multiple.validation') }
      end
    end
  end

  def destroy_multiple
    @units = Unit.where(id: params[:unit_ids])

    respond_to do |format|
      if params[:unit][:confirm] == 'DELETE'
        @units.each { |unit| unit.factions.clear }
        destroyed = @units.destroy_all

        if destroyed.any?
          format.html { redirect_to armies_url, danger: t('messages.multiple.delete', model: t('activerecord.models.unit', count: 2)) }
        else
          format.html { redirect_to armies_url, danger: t('messages.multiple.error', model: t('activerecord.models.unit', count: 2), failed: @units.length) }
        end
      else
        format.html { redirect_to armies_url, danger: t('messages.multiple.validation') }
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

  def check_owner
    units_to_include = [@unit] # Initialize with @army

    if params[:unit_ids].present?
      units_to_include += Unit.where(id: params[:unit_ids]).order(:name)
    end

    if !@current_user&.is_master?
      units_to_include.compact.each do |unit|
        if !@current_user.faction.units.include?(unit)
          respond_to do |format|
            format.html { redirect_to armies_url, danger: t('messages.permissions', model: Unit.model_name.human(:count => 1).downcase) }
            format.js do
              flash[:danger] = t('messages.permissions', model: Unit.model_name.human(:count => 1).downcase)
              render js: "window.location='/armies'"
            end
          end
        end
      end
    end
  end

  def unit_params
    permitted_keys = if @current_user.is_master?
      [
        :name, :location_id, :family_id,
        :count, :count_start, :count_death,
        :strength_mod, :strength_indirect_mod, :hp_mod,
        :visible, :unit_type,
        { faction_ids: [], tags: [] }
      ]
    else
      [:name, { tags: [] }]
    end

    params.require(:unit).permit(*permitted_keys).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
    end
  end
end
