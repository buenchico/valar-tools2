class RecipesController < ApplicationController
  before_action :set_tool
  before_action :check_master
  before_action :set_recipe, only: [:edit, :update, :destroy, :show]
  before_action :set_options

  def index
    @recipes = Recipe.all
    @view = (cookies[:recipe_view] || "cards")
    @not_view = (@view == "cards" ? "table" : "cards")
  end

  def edit
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)

    respond_to do |format|
      if @recipe.save
        flash.now[:success] = t('messages.success.update', thing: @recipe.name.strip + " (id: " + @recipe.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @recipe.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: 'la familia', method: 'create' } }
      end
    end
  end

  def update
    original_name =  @recipe.name
    respond_to do |format|
      if @recipe.update(recipe_params)
        flash.now[:success] = t('messages.success.update', thing: @recipe.name.strip + " (id: " + @recipe.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @recipe.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: original_name + " (id: " + @recipe.id.to_s + ")", method: 'update' } }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @recipe.destroy
        flash.now[:danger] = t('messages.success.destroy', thing: @recipe.name.strip + " (id: " + @recipe.id.to_s + ")", count: 1)
        format.js
      else
        format.html {  redirect_to locations_url, danger: @recipe.errors  }
      end
    end
  end

private
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def set_options
    # Getting missions options
    @options = Tool.find_by(name: "missions").game_tools.find_by(game_id: active_game&.id)&.options
    @sections = @options["sections"]

    if @options.blank?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de recetas'
    end
  end

  def recipe_params
    # Permit the parameters and initialize with sanitized values
    recipe_params = params.require(:recipe).permit(:name, :section, :description, :difficulty, :speed, factors: {}, results: {}).tap do |whitelisted|
      # Clean up empty elements in factors
      whitelisted[:factors] = clean_empty_elements(whitelisted[:factors])
      # Clean up empty elements in results
      whitelisted[:results] = clean_empty_elements(whitelisted[:results])
    end
  end

  # Method to clean up empty elements in a JSON hash
  def clean_empty_elements(json)
    json.transform_values do |array|
      array.reject(&:blank?)
    end
  end
end
