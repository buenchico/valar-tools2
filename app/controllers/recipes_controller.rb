class RecipesController < ApplicationController
  before_action :set_tool
  before_action :check_master
  before_action :set_recipe, only: [:edit, :update, :destroy, :show]
  before_action :set_options

  def index
    @recipes = Recipe.all
  end

  def edit
  end

  def new
    @recipe = Recipe.new
  end

  def create
  end

  def update
  end

  def destroy
  end

private
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def set_options
    @options = Tool.find_by(name: "missions").game_tools.find_by(game_id: active_game&.id)&.options

    if @options.blank?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de recetas'
    end
  end

  def recipe_params
    params.require(:recipe).permit(:name, :section, :description, :difficulty, :speed, :factors, :results)
  end
end
