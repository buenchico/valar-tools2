class LocationsController < ApplicationController
  before_action :set_tool
  before_action :set_location, only: [:edit, :update, :destroy]
  before_action :set_options, only: [:index, :new, :edit]

  def index
    @locations = Location.all
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to locations_url, success: 'Lugar creado correctamente.' }
      else
        format.html {  redirect_to locations_url, danger: @location.errors }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to locations_url, success: 'Lugar editado correctamente.' }
      else
        format.html { redirect_to locations_url, danger: @location.errors }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @location.destroy
        format.html { redirect_to locations_url, success: 'Lugar eliminado correctamente.' }
      else
        format.html {  redirect_to locations_url, danger: @location.errors  }
      end
    end
  end

private
  def set_location
    @location = Location.find(params[:id])
  end

  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
  end

  def location_params
    params.require(:location).permit(:name_en, :name_es, :description, :x, :y, :region, :location_type, :visible, :family_id, :game_id, tags: []).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
    end
  end
end
