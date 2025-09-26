class FamiliesController < ApplicationController
  include ArmiesHelper

  before_action :set_tool
  before_action :check_master, except: [:index, :show]
  before_action :set_family, only: [:edit, :update, :destroy, :show]
  before_action :set_families, only: [:index, :edit, :new]
  before_action :set_factions, only: [:edit, :new]
  before_action :set_options, only: [:index, :new, :edit, :update, :new, :show, :create, :export]
  before_action :set_filters, only: [:index, :show]
  before_action :set_selected_families, onlly: [:index, :update]
  before_action :check_visble, only: [:show]

  def index
  end

  def show
    @vassals = Family.where(lord_id: @family.id).where(game: @family.game).where(visible: true)
    @locations = Location.where(family_id: @family.id).where(game: @family.game).where(visible: true)
    @relations = Family.where("LOWER(members) LIKE ?", "%#{@family.name.downcase}%").where(visible: true).where(game: @family.game).where.not(id: @family.id)
    @army_options = Tool.find_by(name: 'armies').game_tools.find_by(game_id: active_game&.id)&.options
    respond_to do | format |
      format.js
      format.html do
        set_families
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
    @families = Family.where(id: params[:family_ids]).order(:name)
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
    families = Family.where(id: (cookies[:families_select].present? ? JSON.parse(cookies[:families_select]) : []))
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"families.csv\""
        headers['Content-Type'] ||= 'text/csv'

        header_row = ["id", "name", "branch", "tags", "visible", "faction_id", "faction", "lord_id", "lord", "description", "members", "tier"]
        @options_families["loyalties"].each do | value |
          header_row << value
        end
        header_row += ["game_id", "game", "armies_hp_raised", "armies_hp_inactive", "armies_hp_start", "location_total", "location_names"]

        csv_data = CSV.generate(col_sep: ";", headers: true) do |csv|
          csv << header_row # Adjust the attributes as needed

          families.each do |family|
            data_row = [family.id, family.name, family.branch, family.tags.join(","), family.visible, family&.faction&.id, family&.faction&.name, family&.lord&.id, family&.lord&.title, family.description, family.members, family.tier]
            @options_families["loyalties"].each_with_index do | value, index |
              data_row << family["loyalty_#{index + 1}"]
            end
            data_row += [family&.game&.id, family&.game&.name, family.men, family.men_start, family.men_death, family.locations.count, family.locations.map { |l| [l.name, l.location_type] }]
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

  def set_selected_families
    @selected_families = cookies[:families_select].present? ? JSON.parse(cookies[:families_select]) : []
  end

  def set_options
    options = GameOptionsService.fetch

    if options[:families].blank?
      redirect_to settings_url, warning: t('activerecord.errors.messages.options_not_ready', tool_name: @tool.title)
    else
      set_options_armies(options)
      set_options_families(options)
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
      @filter = [t('activerecord.attributes.family.selected'),t('activerecord.attributes.family.name'),t('activerecord.attributes.family.tags'),t('activerecord.attributes.family.lord_id'),t('activerecord.attributes.family.faction_id'),t('activerecord.attributes.family.description'),t('activerecord.attributes.family.game_id')]
    else
      @filter = [t('activerecord.attributes.family.name'),t('activerecord.attributes.family.tags'),t('activerecord.attributes.family.lord_id'),t('activerecord.attributes.family.faction_id'),t('activerecord.attributes.family.description')]
    end
  end

  def family_params
    params.require(:family).permit(:name, :branch, :visible, :lord_id, :game_id, :faction_id, :tier, :members, :description, :loyalty_1, :loyalty_2, :loyalty_3, :loyalty_4, :loyalty_5, tags: []).tap do |whitelisted|
      whitelisted[:tags] = params[:family][:tags].reject(&:empty?)

      if @options_families["tags"] != "false"
        whitelisted[:tags].each do |tag|
          if !@options_families["tags"].include?(tag)
            @options_families["tags"] << tag
          end
          @options_families["tags"] = @options_families["tags"].sort
          @tool.game_tools.find_by(game_id: active_game&.id).update(options: @options_families)
        end
      end
    end
  end
end
