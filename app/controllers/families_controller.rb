class FamiliesController < ApplicationController
  before_action :set_tool
  before_action :check_master, except: [:index, :show]
  before_action :set_family, only: [:edit, :update, :destroy, :show]
  before_action :set_families_list, only: [:index, :export]
  before_action :set_options, only: [:index, :new, :edit, :update, :new, :show, :create, :export]
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
        flash.now[:success] = t('messages.success.update', thing: @family.name.strip + " (id: " + @family.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @family.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: 'la familia', method: 'create' } }
      end
    end
  end

  def edit
  end

  def edit_multiple
    @families = Family.where(id: params[:army_ids]).order(:name)
    @action = params[:button]
  end

  def update
    original_title =  @family.title
    respond_to do |format|
      if @family.update(family_params)
        flash.now[:success] = t('messages.success.update', thing: @family.name.strip + " (id: " + @family.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @family.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: original_title + " (id: " + @family.id.to_s + ")", method: 'update' } }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @family.destroy
        flash.now[:danger] = t('messages.success.destroy', thing: @family.name.strip + " (id: " + @family.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @family.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: @family.name.strip + " (id: " + @family.id.to_s + ")", method: 'delete' } }
      end
    end
  end

  def list
  #Column name must be between double quotes because, by default, pgsql column names are always lowercase
    @families_list = Family.order(:name).where(visible: true).where('LOWER("name") LIKE :term OR LOWER("branch") LIKE :term', term: "%#{params[:term].downcase}%")
    @families_list  = @families_list.limit(20)
    render json: @families_list.map(&:title).uniq
  end

  def export
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"families.csv\""
        headers['Content-Type'] ||= 'text/csv'

        header_row = ["id", "name", "branch", "tags", "visible", "armies_hp_raised", "armies_hp_start", "armies_hp_inactive", "faction_id", "faction", "lord_id", "lord", "description", "members", "game_id", "game"]
        @options["loyalties"].each do | value |
          header_row << value
        end

        csv_data = CSV.generate(col_sep: ";", headers: true) do |csv|
          csv << header_row # Adjust the attributes as needed

          @families.each do |family|
            data_row = [family.id, family.name, family.branch, family.tags.join(","), family.visible, family.hp_raised, family.hp_start, family.hp_inactive, family&.faction&.id, family&.faction&.name, family&.lord&.id, family&.lord&.title, family.description, family.members, family&.game&.id, family&.game&.name]
            @options["loyalties"].each_with_index do | value, index |
              data_row << family["loyalty_#{index}"]
            end
            csv << data_row
          end
        end

        render plain: csv_data
      end
    end
  end

private
  def set_family
    @family = Family.find(params[:id])
  end

  def set_families_list
    if @current_user&.is_admin?
      @families = Family.all.order(:name)
    elsif @current_user&.is_master?
      @families = Family.where(game_id: active_game.id).order(:name)
    else
      @families = Family.where(visible: true).where(game_id: active_game.id).order(:name)
    end
  end

  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    if @options.blank?
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
    params.require(:family).permit(:name, :branch, :visible, :lord_id, :game_id, :faction_id, :members, :description, :loyalty_1, :loyalty_2, :loyalty_3, :loyalty_4, :loyalty_5, tags: []).tap do |whitelisted|
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
