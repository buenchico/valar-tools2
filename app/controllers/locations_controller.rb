class LocationsController < ApplicationController
  before_action :set_tool
  before_action :check_master, except: [:show, :list]
  before_action :set_location, only: [:edit, :show, :update, :destroy]
  before_action :set_locations_list, only: [:index]
  before_action :set_regions, except: [:index]
  before_action :set_options
  before_action :set_filters, only: [:index]

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

  def export
    locations = Location.all
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"families.csv\""
        headers['Content-Type'] ||= 'text/csv'

        header_row = ["id", "name_es", "name_en", "description", "location_type", "visible", "family_id", "region_id", "game_id"]

        csv_data = CSV.generate(col_sep: ";", headers: true) do |csv|
          csv << header_row # Adjust the attributes as needed

          locations.each do |location|
            data_row = [location.id, location.name_es, location.name_en, location.description, location.location_type, location.visible, location.family_id, location.region_id, location.game_id]
            csv << data_row
          end
        end

        render plain: csv_data
      end
    end
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

  def set_filters
    if @current_user&.is_master?
      @filter = [
        t('activerecord.attributes.location.name_es'),
        t('activerecord.attributes.location.name_en'),
        t('activerecord.attributes.location.description'),
        t('activerecord.attributes.location.tags'),
        t('activerecord.attributes.location.location_type'),
        t('activerecord.attributes.location.region'),
        t('activerecord.attributes.location.family_id'),
        t('activerecord.attributes.location.visible'),
        t('activerecord.attributes.location.game_id')
      ]
    else
      @filter = [
        t('activerecord.attributes.location.name_es'),
        t('activerecord.attributes.location.name_en'),
        t('activerecord.attributes.location.description'),
        t('activerecord.attributes.location.tags'),
        t('activerecord.attributes.location.location_type'),
        t('activerecord.attributes.location.region'),
        t('activerecord.attributes.location.family_id'),
        t('activerecord.attributes.location.visible')
      ]
    end
  end
end
