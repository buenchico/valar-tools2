class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy]
  before_action :set_options, only: [:index, :edit, :update, :new]
  before_action :set_factions, only: [:edit, :new]
  before_action :set_filters, only: [:index]
  before_action :check_master, only: [:destroy, :destroy_multiple]
  before_action :check_owner, only: [:edit, :edit_notes, :update]

  def index
    @faction = @current_user.faction.name
    if @current_user.is_master?
      @all_armies = Army.all.order(:group)
      @factions = Faction.where(active: true).order(:id).drop(1)
    else
      @armies = Army.joins(:factions).where(factions: { id: @current_user.faction_id }).distinct
    end
  end

  def new
    @army = Army.new
  end

  def create
    @army = Army.new(army_params)

    respond_to do |format|
      if @army.save
        format.html { redirect_to armies_url, success: 'Ejército creado correctamente.' }
      else
        format.html {  redirect_to armies_url, danger: @army.errors }
      end
    end
  end

  def edit
  end

  def edit_notes
  end

  def edit_multiple
    @armies = Army.where(id: params[:army_ids]).order(:name)
    @action = params[:button]

    @armies.each do | army |
      if !@current_user.is_master?
        if !@current_user.faction.armies.include?(army)
          flash[:danger] = 'No tienes permisos para editar esos ejércitos.'
          render js: "window.location='/armies'"
        end
      end
    end
  end

  def update

    if !@current_user.is_master? # modify params if user is not admin
      keys_to_remove = ["tags", "region", "lord", "visible", "hp",
        "col0", "col1", "col2", "col3", "col4", "col5", "col6", "col7", "col8", "col9", "faction_ids"]
        if @army.status == ARMY_STATUS[-1]
          keys_to_remove << "status"
        end
    end

    respond_to do |format|
      if @army.update(army_params.reject! { |x| keys_to_remove&.include?(x) })
        format.html { redirect_to armies_url, success: 'Ejército editado correctamente.' }
      else
        format.html { redirect_to armies_url, danger: @army.errors }
      end
    end
  end

  def update_multiple
    @armies = Army.where(id: params[:army_ids])

    army_params_hash = {}
    army_params.to_hash.each do | key, value |
      unless value.blank?
        if key == "position"
          if value == "CLEAR"
            army_params_hash[key] = nil
          else
            army_params_hash[key] = value
          end
        end
        if (key == "group")
          if (ARMY_GROUPS.keys.map { |k| k.to_s }).include?(value.to_s)
            army_params_hash[key] = value
          end
        end
        if (key == "status")
          if @current_user.is_admin? # Checking the user is admin to modify the status
            if ARMY_STATUS.include?(value.to_s)
              army_params_hash[key] = value
            end
          end
        end
      end
    end

    respond_to do |format|
      if params[:army][:confirm] == 'VALIDATE'
        if army_params_hash.empty?
          format.html { redirect_to armies_url, success: 'Nada que actualizar.' }
        else
          if @armies.update_all(army_params_hash)
            format.html { redirect_to armies_url, success: 'Ejércitos editados correctamente.' }
          else
            format.html { redirect_to armies_url, danger: 'Ha ocurrido un error, por favor, intentalo de nuevo más tarde.' }
          end
        end
      else
        format.html { redirect_to armies_url, danger: 'La palabra de validación es incorrecta.' }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @army.destroy
        format.html { redirect_to armies_url, success: 'Ejército eliminado correctamente.' }
      else
        format.html {  redirect_to armies_url, danger: @army.errors  }
      end
    end
  end

  def destroy_multiple
    @armies = Army.where(id: params[:army_ids])

    respond_to do |format|
      if params[:army][:confirm] == 'DELETE'
        if @armies.delete_all
          format.html { redirect_to armies_url, success: 'Ejércitos eliminados correctamente.' }
        else
          format.html { redirect_to armies_url, danger: 'Ha ocurrido un error, por favor, intentalo de nuevo más tarde.' }
        end
      else
        format.html { redirect_to armies_url, danger: 'La palabra de validación es incorrecta.' }
      end
    end
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    if @options.nil?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de ejércitos'
    end
  end

  def set_army
    @army = Army.find(params[:id])
  end

  def set_factions
    @factions = Faction.where(active: true).order(:name).offset(0)
  end

  def set_filters
    if @current_user&.is_master?
      @filter = [ "Ejército", "Estado", "Rasgos", "Posición", "Grupo", "Visibilidad" ]
    else
      @filter = [ "Ejército", "Rasgos", "Posición", "Grupo" ]
    end
  end

  def check_owner
    if !@current_user.is_master?
      if !@current_user.faction.armies.include?(@army)
        flash[:danger] = 'No tienes permisos para editar ese ejército.'
        render js: "window.location='/armies'"
      end
    end
  end

  def army_params
    params.require(:army).permit(
      :name, :status, :position, :group, :region, :lord, :confirm,
      :visible, :hp, :col0, :col1, :col2, :col3, :col4, :col5, :col6, :col7, :col8, :col9, :notes, faction_ids: [], tags: []
    ).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
    end
  end
end
