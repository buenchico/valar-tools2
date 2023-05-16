class ArmiesController < ApplicationController
  before_action :check_player
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy]
  before_action :set_options, only: [:index, :edit, :update, :new]
  before_action :set_factions, only: [:edit, :new]
  before_action :set_filters, only: [:index]

  def index
    if @current_user.is_master?
      @armies = Army.all.order(:group)
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

  def update
    respond_to do |format|
      if @army.update(army_params)
        format.html { redirect_to armies_url, success: 'Ejército editado correctamente.' }
        format.js
      else
        format.html { redirect_to armies_url, danger: @army.errors }
      end
    end
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game.id).options
    if @options.nil?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de ejércitos'
    end
  end

  def set_army
    @army = Army.find(params[:id])
  end

  def set_factions
    @factions = Faction.where(active: true).order(:name).offset(3)
  end

  def set_filters
    if @current_user&.is_master?
      @filter = [ "Ejército", "Estado", "Rasgos", "Posición", "Grupo", "Visibilidad" ]
    else
      @filter = [ "Ejército", "Rasgos", "Posición", "Grupo" ]
    end
  end

  def army_params
    params.require(:army).permit(
      :name, :status, :position, :group, :region, :lord,
      :visible, :col0, :col1, :col2, :col3, :col4, :col5, :col6, :col7, :col8, :col9, :notes, faction_ids: [], tags: []
    ).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
    end
  end
end
