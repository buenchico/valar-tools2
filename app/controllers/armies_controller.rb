class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy, :show, :delete, :show]
  before_action :set_options
  before_action :set_factions, only: [:index, :stats, :new, :edit, :edit_multiple]
  before_action :check_master, only: [:new, :edit, :delete, :create, :destroy, :delete, :damage_multiple, :damage_multiple_apply, :merge_multiple, :stats]
  before_action :check_owner_inclusive, only: [:show]

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

  def stats
    @armies = Army.all
    @units = Unit.all
  end

  def show_armies
    active_factions = JSON.parse(params[:active_factions])
    active_visibility = JSON.parse(params[:active_visibility])

    @armies, units = get_armies(active_factions, active_visibility)
    @units = units.where(army: nil)
  end

  def delete
  end

  def edit
  end

  def edit_notes
  end

  def edit_multiple
    army_ids = params[:army_ids].split(',')
    @armies = Army.where(id: army_ids).order(:name)
    @army_types = @armies.map(&:army_type).uniq
    @units = @armies.includes(:units).flat_map(&:units).uniq
    @template = 'form_' + params[:button] + '_multiple'
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
    army_params = self.army_params # This is needed to be able to redefine army_params later

    if params[:source] == 'units'
      @new_unit_ids = params["unit_ids"]
      old_unit_ids = @army.unit_ids
      unit_ids = @new_unit_ids.concat(old_unit_ids)
      army_params = army_params.merge(unit_ids: unit_ids)
    end

    if params[:source] == 'army_form'
      old_unit_ids = @army.units.pluck(:id).map(&:to_s)
      @removed_unit_ids = Array(old_unit_ids).compact - Array(army_params[:unit_ids]).compact
    end

    respond_to do |format|
      if params[:confirm].nil? || params[:confirm] == 'VALIDATE'
        puts army_params
        if @army.update(army_params)
          flash.now[:success] = t('messages.success.update', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
          format.js
        else
          flash.now[:danger] = @army.errors.to_hash
          format.js { render 'layouts/error', locals: { thing: @army.name.strip + " (id: " + @army.id.to_s + ")", method: 'update' } }
        end
      else
        flash.now[:danger] = t('messages.validation')
        format.js { render 'layouts/error' }
      end
    end
  end

  def update_multiple
    @armies = Army.where(id: params[:army_ids])

    army_params = { change: {}, sum: {}, add: {}, remove: {} }

    army_params[:change][:xp] = params["army"]["xp_change"] unless params["army"]["xp_change"].empty?
    army_params[:sum][:xp] = params["army"]["xp_sum"] unless params["army"]["xp_sum"].empty?
    army_params[:change][:morale] = params["army"]["morale_change"] unless params["army"]["morale_change"].empty?
    army_params[:sum][:morale] = params["army"]["morale_sum"] unless params["army"]["morale_sum"].empty?
    army_params[:add][:tags] = params["army"]["tags_add"].reject(&:empty?)
    army_params[:remove][:tags] = params["army"]["tags_remove"].reject(&:empty?)
    army_params[:change][:visible] = params["army"]["visible"] unless params["army"]["visible"].empty?
    army_params[:change][:position] = params["army"]["position"] unless params["army"]["position"].empty?
    army_params[:change][:group] = params["army"]["group"] unless params["army"]["group"].empty?
    army_params[:change][:status] = params["army"]["status"] unless params["army"]["status"].empty?

    @errors_armies = []
    @updated_armies = []

    respond_to do |format|
      if params[:army][:confirm] == 'VALIDATE'
        if army_params.values.map(&:values).flatten.compact.empty? # all values are empty
          format.html { redirect_to armies_url, success: t('messages.multiple.nothing') }
        else
          @armies.each do |army|
            army_params[:sum].each do |key, value|
              if army.respond_to?(key)
                old_value = army[key]
                army.send("#{key}=", (old_value += value))
              end
            end

            army_params[:change].each do |key, value|
              if army.respond_to?(key)
                army.send("#{key}=", value)
              end
            end

            army_params[:add].each do |key, value|
              if army.respond_to?(key)
                old_value = army[key]
                army.send("#{key}=", (old_value + value))
              end
            end

            army_params[:remove].each do |key, value|
              if army.respond_to?(key)
                old_value = army[key]
                army.send("#{key}=", (old_value - value))
              end
            end

            if army.save
              @updated_armies << army
            else
              @errors_armies << (army.name.to_s + " | " + army.errors.full_messages.join(", "))
            end
          end

          if @errors_armies.length == 0
            flash[:success] = t('messages.multiple.success', model: Army.model_name.human(:count => @updated_armies.length), succeed: ("<br>" + @updated_armies.pluck(:name).join("<br>")).html_safe)
            format.js
          else
            flash[:danger] = t('messages.multiple.error', model: Army.model_name.human(:count => @errors_armies.length), failed: ("<br>" + @errors_armies.join("<br>") + "<br>").html_safe, succeed: ("<br>" + @updated_armies.pluck(:name).join("<br>")).html_safe)
            format.js
          end
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

  def destroy_multiple
    @armies = Army.where(id: params[:army_ids])

    respond_to do |format|
      if params[:confirm].nil? || params[:confirm] == 'DELETE'
        @destroyed = []
        @failed = []
        @units = []

        @armies.each do |army|
          released_units = army.units.to_a
          if army.destroy
            @destroyed << army
            @units.concat(released_units)
          else
            @failed << { army: army, errors: army.errors.to_hash }
          end
        end

        if @failed.empty?
          flash.now[:danger] = t('messages.multiple.success', model: (t('activerecord.models.army', count: @destroyed.size)), succeed: @destroyed.size)
          format.js
        else
          flash.now[:danger] = t('messages.multiple.error', model: (t('activerecord.models.army', count: @failed.size)), succeed: @destroyed.size, failed: @failed.size)
          format.js { render 'layouts/error', locals: { method: 'delete', thing: 'multiple armies' } }
        end
      else
        flash.now[:danger] = t('messages.validation')
        format.js { render 'layouts/error' }
      end
    end
  end

  def damage_multiple
    @units = Unit.where(id: params[:unit_ids])
    @armies = Army.where(id: params[:army_ids])
    damage = params[:army][:damage].to_i * @army_scale # 1 dmg kills 1 scale of hp
    times = params.dig(:army, :times).presence&.to_i || 1

    damage_log = DamageSimulator.simulate_damage(units: @units, damage: damage, times: times)
    @damage_log_by_armies = damage_log.values.group_by { |unit| unit[:army_id] }
    @totals_by_army = @damage_log_by_armies.transform_values do |units|
      {
        total_damage: units.sum { |u| u[:damage].to_f },
        total_losses: units.sum { |u| u[:unit_losses].to_f }
      }
    end

    respond_to do |format|
      if times > 1
        flash[:danger] = "Check logfile.txt for development logs"
        format.js { render 'layouts/development' }
      else
        format.js
      end
    end
  end

  def damage_multiple_apply
    units = Unit.where(id: params[:unit_ids])

    @updated_armies = []
    @errors_units = []

    params[:units].each do |unit_fields|
      unit = units.find_by(id: unit_fields["id"])
      unit.count = unit_fields["count"]

      if unit.save
        @updated_armies << unit.army
      else
        @errors_units << (unit.name.to_s + " | " + unit.errors.full_messages.join(", "))
      end
    end

    respond_to do |format|
      if params[:army][:confirm] == 'DAMAGE'
        if @errors_units.length == 0
          flash[:success] = t('messages.multiple.success', model: Army.model_name.human(:count => @updated_armies.length), succeed: ("<br>" + @updated_armies.pluck(:name).join("<br>")).html_safe)
          format.js { render 'update_multiple'}
        else
          flash[:danger] = t('messages.multiple.error', model: Unit.model_name.human(:count => @errors_units.length), failed: ("<br>" + @errors_units.join("<br>") + "<br>").html_safe, succeed: ("<br>" + @updated_units.pluck(:name).join("<br>")).html_safe)
          format.js { render 'layouts/error' }
        end
      else
        flash.now[:danger] = t('messages.validation')
        format.js { render 'layouts/error' }
      end
    end
  end

  def merge_multiple
    armies = Army.where(id: params["army_ids"]).order(:name)
    units = Unit.where(id: params["unit_ids"]).order(:name)
    xp = armies.minimum(:xp)
    morale = armies.minimum(:morale)
    position = armies.pluck(:position).uniq.join(', ')
    notes = armies.pluck(:position).uniq.join(', ')
    tags = armies.pluck(:tags).flatten.uniq
    visible = (armies.all.pluck(:visible).uniq == [true]) ? true : false
    name = params[:army][:name]
    status = params[:army][:status]
    logs = [
      {
        timestamp: Time.now,
        user_id: @current_user.id, # Set the current user appropriately
        username: @current_user.player,
        changes: ["Army created from merging armies: #{params["army_ids"].join(", ")}"]
      }
    ]

    @army = Army.new(name: name, position: position, notes: notes, status: status, xp: xp, morale: morale, visible: visible, tags: tags, logs: logs)
    @army.units = units

    respond_to do |format|
      if params[:army][:confirm] == 'VALIDATE'
        if @army.save
          armies.delete_all
          @old_army_ids = params["army_ids"]
          flash.now[:success] = t('messages.success.create', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
          format.js { render 'create'}
        else
          flash.now[:danger] = @army.errors.to_hash
          format.js { render 'layouts/error', locals: { thing: name , method: 'create' } }
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

  def check_owner_exclusive
    check_owner("exclusive")
  end

  def check_owner_inclusive
    check_owner("inclusive")
  end

  def check_owner(type)
    armies_to_include = [@army] # Initialize with @army

    if params[:army_ids].present?
      armies_to_include += Army.where(id: params[:army_ids]).order(:name)
    end

    units = Unit.where(army_id: armies_to_include)

    if !@current_user&.is_master?
      if type == "exclusive"
        pass = units.all? { |unit| unit.factions.include?(@current_user.faction) }
      else
        pass = units.any? { |unit| unit.factions.include?(@current_user.faction) }
      end

      if pass == false
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

  def army_params
    params.require(:army).permit(
      :name, :status, :position, :group,
      :visible, :notes, :xp, :morale, tags: [], unit_ids: [],
      units_attributes: [:id, :count]
    ).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
    end
  end
end
