class BattlesController < ApplicationController
  before_action :set_tool
  before_action :check_master
  before_action :set_battle, only: [:edit, :update, :destroy, :show]

  def index
    @battles = Battle.all
  end

  def new
    @battle = Battle.new
  end

  def create
    @battle = Battle.new(battle_params)

    respond_to do |format|
      if @battle.save
        flash.now[:success] = t('messages.success.update', thing: @battle.name.strip + " (id: " + @battle.id.to_s + ")", count: 1)
        format.js
      else
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

  def battle_params
    params.require(:battle).permit(:name, :date, :status, :terrain, :sideA, :sideB)
  end
end
