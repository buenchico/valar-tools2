class FamiliesController < ApplicationController
  before_action :set_tool
  before_action :set_family, only: [:edit, :update, :destroy]
  before_action :set_options, only: [:new, :edit, :update, :new]

  def index
    @families = Family.all
  end

  def new
    @family = Family.new
  end

  def create
    @family = Family.new(family_params)

    respond_to do |format|
      if @family.save
        format.html { redirect_to families_url, success: 'Familia creada correctamente.' }
      else
        format.html {  redirect_to families_url, danger: @family.errors }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @family.update(family_params)
        format.html { redirect_to families_url, success: 'Familia editada correctamente.' }
      else
        format.html { redirect_to families_url, danger: @family.errors }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @family.destroy
        format.html { redirect_to families_url, success: 'Familia eliminada correctamente.' }
      else
        format.html {  redirect_to families_url, danger: @family.errors  }
      end
    end
  end

private
  def set_family
    @family = Family.find(params[:id])
  end

  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    if @options.nil?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de familias'
    end
  end

  def family_params
    if params["family"]["tags"].is_a?(Array)
      permitted_params = params.require(:family).permit(:name, :branch, :visible, :game_id, tags: [])
      tags = params["family"]["tags"].reject(&:empty?)
    else
      # If tags is a string, split it into an array and process it
      permitted_params = params.require(:family).permit(:name, :branch, :visible, :game_id, :tags)
      tags = params["family"]["tags"].split(',').map(&:strip).reject(&:empty?)
    end

    if !@options["tags"].nil?
      tags.each do | tag |
        if !@options["tags"].include?(tag)
          @options["tags"] << tag
        end
        @tool.game_tools.find_by(game_id: active_game&.id).update(options: @options)
      end
    end

    permitted_params[:tags] = tags

    permitted_params
  end
end
