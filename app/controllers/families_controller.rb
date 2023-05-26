class FamiliesController < ApplicationController
  before_action :set_tool
  before_action :set_family, only: [:edit, :update, :destroy]
  before_action :set_options, only: [:new, :edit]

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
  end

  def family_params
    params.require(:family).permit(:name, :branch, :visible, :game_id, tags: []).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
    end
  end
end
