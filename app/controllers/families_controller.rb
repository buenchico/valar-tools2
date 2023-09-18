class FamiliesController < ApplicationController
  before_action :set_tool
  before_action :check_master, except: [:index, :show]
  before_action :set_family, only: [:edit, :update, :destroy, :show]
  before_action :set_families_list, only: [:index]
  before_action :set_options, only: [:index, :new, :edit, :update, :new, :show, :create]
  before_action :set_filters, only: [:index, :show]
  before_action :check_visble, only: [:show]

  def index
  end

  def show
    @vassals = Family.where(lord_id: @family.id)
    @locations = Location.where(family_id: @family.id)
    @relations = Family.where("members LIKE ?", "%#{@family.name}%").where.not(id: @family.id)
    respond_to do | format |
      format.js
      format.html do
        set_families_list
      end
    end
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

  def list
  #Column name must be between double quotes because, by default, pgsql column names are always lowercase
    @families_list = Family.order(:name).where(visible: true).where('LOWER("name") LIKE :term OR LOWER("branch") LIKE :term', term: "%#{params[:term].downcase}%")
    @families_list  = @families_list.limit(20)
    render json: @families_list.map(&:title).uniq
  end

private
  def set_family
    @family = Family.find(params[:id])
  end

  def set_families_list
    if @current_user&.is_master?
      @families = Family.all.order(:name)
    else
      @families = Family.where(visible: true).where(game_id: active_game.id).order(:name)
    end
  end

  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    $options_families = @options
    if @options.nil?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de familias'
    end
  end

  def check_visble
    if !@current_user&.is_master?
      if !(@family.game == active_game && @family.visible == true)
        respond_to do |format|
          flash[:danger] = 'No tienes permisos para acceder a esta familia.'
          format.js { render js: "window.location='/families'" }
          format.html { redirect_to families_url }
        end
      end
    end
  end

  def set_filters
    if @current_user&.is_master?
      @filter = ["Nombre","Etiquetas","Señor","Facción","Descripcción","Partida"]
    else
      @filter = ["Nombre","Etiquetas","Señor","Facción","Descripcción"]
    end
  end

  def family_params
    params.require(:family).permit(:name, :branch, :visible, :lord_id, :game_id, :faction_id, :members, :description, :loyalty_1, :loyalty_2, :loyalty_3, :loyalty_4, :loyalty_5, :tags).tap do |whitelisted|
      whitelisted[:tags] = params[:family][:tags].reject(&:empty?)

      if @options["tags"] != "false"
        whitelisted[:tags].each do |tag|
          if !@options["tags"].include?(tag)
            @options["tags"] << tag
          end
          @options["tags"] = @options["tags"].sort
          @tool.game_tools.find_by(game_id: active_game&.id).update(options: @options)
        end
      end
    end
  end
end
