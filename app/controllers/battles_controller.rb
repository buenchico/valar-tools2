class BattlesController < ApplicationController
  before_action :set_tool
  before_action :check_master
  before_action :set_battle, only: [:edit, :update, :destroy, :show, :add_armies, :update_armies]
  before_action :set_factions, only: [:add_armies]
  before_action :set_options
  before_action :set_army_options, only: [:edit]

  def index
    if @current_user&.is_master?
      @battles = Battle.all.order(:id)
    else
      @battles = Battle.where(user: @current_user)
    end
  end

  def edit
  end

  def new
    @battle = Battle.new
  end

  def update
    battle_params_with_status = battle_params.merge("status": @battle.status + 1)

    respond_to do |format|
      if @battle.update(battle_params_with_status)
        flash[:success] = t('messages.success.update', thing: @battle.name.strip + " (id: " + @battle.id.to_s + ")", count: 1)
        format.html { redirect_to edit_battle_path(@battle) }
      else
        flash[:danger] = @battle.errors.to_hash
        format.html { render :edit }
      end
    end
  end

  def add_armies
    @side = params[:side]
  end

  def update_armies
    phase = @options["status"][@battle.status]["code"].to_sym
    army_ids = params[:army_ids]
    # get the phase data
    side = params[:battle][:side]

    data = @battle.send(phase)

    # Ensure "armies" key exists
    data["armies"] ||= {}

    # Ensure the specific side key exists
    data["armies"][side] ||= {}

    armies = data["armies"][side]
    new_armies = Army.where(id: army_ids)

    new_armies.each do | army |
      armies[army.id] = army.as_json(except: [:notes, :visible, :logs, :updated_at, :created_at, :location_id, :family_id], methods: [:men0, :strength])
    end

    # Update the specific side with new data
    data["armies"][side] = armies

    respond_to do |format|
      if @battle.update(phase => data)
        flash[:success] = t('messages.success.update', thing: @battle.name.strip + " (id: " + @battle.id.to_s + ")", count: 1)
        format.html { redirect_to edit_battle_path(@battle) }
      else
        flash[:danger] = @battle.errors.to_hash
        format.html { render :edit }
      end
    end
  end

  def create
    battle_params_mod = battle_params.merge(user_id: @current_user.id).merge(status: 0)

    @battle = Battle.new(battle_params_mod)

    respond_to do |format|
      if @battle.save
        flash.now[:success] = t('messages.success.update', thing: @battle.name.strip + " (id: " + @battle.id.to_s + ")", count: 1)
        format.js
      else
        puts @battle.errors
        flash.now[:danger] = @battle.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: 'la batalla', method: 'create' } }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @battle.destroy
        flash.now[:danger] = t('messages.success.destroy', thing: @battle.name.strip + " (id: " + @battle.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @battle.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: @battle.name.strip + " (id: " + @battle.id.to_s + ")", method: 'delete' } }
      end
    end
  end

private
  def set_battle
    @battle = Battle.find(params[:id])
  end

  def set_factions
    @factions = Faction.where.not(name: ['admin','player']).where(active: true).order(:id)
  end

  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    if @options.blank?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la calculadora de batallas'
    else
      @status = @options["status"]
      @token_status = @options["tokens"]
      $options_battles = @options
    end
  end

  def set_army_options
    options = Tool.find_by(name: 'armies').game_tools.find_by(game_id: active_game&.id)&.options
    if options.blank?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de ejércitos'
    else
      @attributes = options["attributes"]&.sort_by { |_, v| v["sort"] }.to_h
      @fleets = options["fleets"]
      @men = options["men"]&.sort_by { |_, v| v["sort"] }.to_h
      @tags = options["tags"]&.sort_by { |key, _value| key }.to_h
      @army_status = options["status"]
      @army_types = options["army_type"]&.sort_by { |_, v| v["sort"] }.to_h
      @hp = options["hp"]
    end
  end

  def battle_params
    params.require(:battle).permit(:name, :date, :status, :terrain, :user_id, :skirmish, :engagement, :combat_1, :combat_2, :combat_3, :side_a, :side_b)
  end
end
