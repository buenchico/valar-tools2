class BattlesController < ApplicationController
  before_action :set_tool
  before_action :check_master
  before_action :set_battle, only: [:edit, :update, :destroy, :show, :add_tokens, :update_tokens]
  before_action :set_options

  def index
    if @current_user&.is_master?
      @battles = Battle.all.order(:id)
    else
      @battles = Battle.where(user: @current_user)
    end

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

  def add_tokens
    @side = params[:side]
  end

  def update_tokens

    phase = @options["status"][@battle.status]["code"].to_sym
    data = @battle.send(phase)
    data["tokens"] = params[:battle]

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

  def battle_params
    params.require(:battle).permit(:name, :date, :status, :terrain, :user_id, :skirmish, :engagement, :combat_1, :combat_2, :combat_3, :side_a, :side_b)
  end
end
