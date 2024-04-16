class BattlesController < ApplicationController
  before_action :set_tool
  before_action :check_master
  before_action :set_battle, only: [:edit, :update, :destroy, :show]
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

  def create
    battle_params_mod = battle_params.merge(user_id: @current_user.id)

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
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la calculadora de ejércitos'
    end
  end

  def battle_params
    params.require(:battle).permit(:name, :date, :status, :terrain, :sideA, :sideB, :user_id)
  end
end
