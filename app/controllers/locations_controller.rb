class LocationsController < ApplicationController
  before_action :set_tool
  before_action :check_master, except: [:show, :list]
  before_action :set_location, only: [:edit, :show, :update, :destroy]
  before_action :set_locations_list, only: [:index]
  before_action :set_regions, except: [:index]
  before_action :set_options

  def index
  end

  def show
    respond_to do | format |
      format.js
      format.html do
        set_locations_list
      end
    end
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
        format.html { redirect_to locations_url, danger: @location.errors }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @location.update(location_params)
        flash.now[:success] = t('messages.success.update', thing: @location.name.strip + " (id: " + @location.id.to_s + ")", count: 1)
        format.js
      else
        format.html { redirect_to locations_url, danger: @location.errors }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @location.destroy
        flash.now[:danger] = t('messages.success.destroy', thing: @location.name.strip + " (id: " + @location.id.to_s + ")", count: 1)
        format.js
      else
        format.html {  redirect_to locations_url, danger: @location.errors  }
      end
    end
  end

  def list
  #Column name must be between double quotes because, by default, pgsql column names are always lowercase
    @locations_list = Location.order(:name_es).where(visible: true).where(game_id: active_game.id).where('LOWER("name_es") LIKE :term OR LOWER("name_en") LIKE :term', term: "%#{params[:term].downcase}%")
    @locations_list  = @locations_list.limit(20)
    render json: @locations_list.map(&:name_es).uniq
  end

private
  def set_location
    @location = Location.find(params[:id])
  end

  def set_locations_list
    if @current_user&.is_admin?
      @locations = Location.all
    elsif @current_user&.is_master?
      @locations = Location.where(game_id: active_game.id)
    else
      @locations = Location.where(visible: true).where(game_id: active_game.id)
    end
  end

  def set_options
    @options_locations = get_options(@tool)
    if @options_locations.blank?
      redirect_to settings_url, warning: t('activerecord.errors.messages.options_not_ready', tool_name: @tool.title)
    else
      set_options_locations
    end
  end

  def location_params
    params.require(:location).permit(:name_en, :name_es, :description, :x, :y, :line, :polygon, :priority, :region_id, :location_type, :visible, :family_id, :game_id, tags: []).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
    end
  end
end
