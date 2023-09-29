class RecipeController < ApplicationController
  def get_recipe
    @recipe = Recipe.find_by(id: params[:recipe])
  end
end
