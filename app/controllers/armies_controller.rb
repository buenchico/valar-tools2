class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy]
  before_action :set_options, only: [:index, :edit, :update, :new, :export]
  before_action :set_factions, only: [:edit, :new]
  before_action :set_filters, only: [:index]
  before_action :check_player
  before_action :check_master, only: [:destroy, :destroy_multiple]
  before_action :check_owner, only: [:edit, :edit_notes, :update]
  before_action :set_regions, only: [:new, :edit]

  def index
    @faction = @current_user.faction.long_name
    if @current_user.is_master?
      @all_armies = Army.all.order(:group)
      @factions = Faction.where(active: true).order(:id).drop(1)
    else
      @armies = Army.joins(:factions).where(factions: { id: @current_user.faction_id }).distinct
    end
  end

  def new
    @army = Army.new
  end

  def create
    @army = Army.new(army_params)

    respond_to do |format|
      if @army.save
        format.html { redirect_to armies_url, success: 'Ejército creado correctamente.' }
      else
        format.html {  redirect_to armies_url, danger: @army.errors }
      end
    end
  end

  def edit
  end

  def edit_notes
  end

  def edit_multiple
    @armies = Army.where(id: params[:army_ids]).order(:name)
    @action = params[:button]

    @armies.each do | army |
      if !@current_user.is_master?
        if !@current_user.faction.armies.include?(army)
          flash[:danger] = 'No tienes permisos para editar esos ejércitos.'
          render js: "window.location='/armies'"
        end
      end
    end
  end

  def update
    if !@current_user.is_master? # modify params if user is not admin
      keys_to_remove = ["tags", "region", "lord", "visible", "hp",
        "col0", "col1", "col2", "col3", "col4", "col5", "col6", "col7", "col8", "col9", "faction_ids"]
        if @army.status == ARMY_STATUS[-1]
          keys_to_remove << "status"
        end
    end

    respond_to do |format|
      if @army.update(army_params.reject! { |x| keys_to_remove&.include?(x) })
        format.html { redirect_to armies_url, success: 'Ejército editado correctamente.' }
        format.js
      else
        format.html { redirect_to armies_url, danger: @army.errors }
      end
    end
  end

  def update_multiple
    @armies = Army.where(id: params[:army_ids])

    army_params_hash = {}
    army_params.to_hash.each do | key, value |
      unless value.blank?
        if key == "position"
          if value == "CLEAR"
            army_params_hash[key] = nil
          else
            army_params_hash[key] = value
          end
        end
        if (key == "group")
          if value == "CLEAR"
            army_params_hash[key] = nil
          else (ARMY_GROUPS.keys.map { |k| k.to_s }).include?(value.to_s)
            army_params_hash[key] = value
          end
        end
        if (key == "status")
          if @current_user.is_admin? # Checking the user is admin to modify the status
            if ARMY_STATUS.include?(value.to_s)
              army_params_hash[key] = value
            end
          end
        end
      end
    end

    respond_to do |format|
      if params[:army][:confirm] == 'VALIDATE'
        if army_params_hash.empty?
          format.html { redirect_to armies_url, success: 'Nada que actualizar.' }
        else
          if @armies.update_all(army_params_hash)
            format.html { redirect_to armies_url, success: 'Ejércitos editados correctamente.' }
          else
            format.html { redirect_to armies_url, danger: 'Ha ocurrido un error, por favor, intentalo de nuevo más tarde.' }
          end
        end
      else
        format.html { redirect_to armies_url, danger: 'La palabra de validación es incorrecta.' }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @army.destroy
        format.html { redirect_to armies_url, success: 'Ejército eliminado correctamente.' }
      else
        format.html {  redirect_to armies_url, danger: @army.errors  }
      end
    end
  end

  def destroy_multiple
    @armies = Army.where(id: params[:army_ids])

    respond_to do |format|
      if params[:army][:confirm] == 'DELETE'
        if @armies.delete_all
          format.html { redirect_to armies_url, success: 'Ejércitos eliminados correctamente.' }
        else
          format.html { redirect_to armies_url, danger: 'Ha ocurrido un error, por favor, intentalo de nuevo más tarde.' }
        end
      else
        format.html { redirect_to armies_url, danger: 'La palabra de validación es incorrecta.' }
      end
    end
  end

  def export
    @armies = Army.all

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"armies.csv\""
        headers['Content-Type'] ||= 'text/csv'

        header_row = ["id", "name", "status", "position", "group", "factions", "hp *(#{@options["hp"]["step"]})", "tags"] # Adjust the attributes as needed
        @attributes.each do | key, value |
          header_row << "col#{value['sort']} #{key} *(#{value["str"]})"
        end

        csv_data = CSV.generate(col_sep: ";", headers: true) do |csv|
          csv << header_row # Adjust the attributes as needed

          @armies.each do |army|
            data_row = [army.id, army.name, army.status, army.position, army.group, army.factions.pluck(:name).join(","), army.hp, army.tags.join(",")]
            @attributes.each do | key, value |
              data_row << army["col#{value['sort']}"]
            end
            csv << data_row
          end
        end

        render plain: csv_data
      end
    end
  end

  def import
    respond_to do |format|
      if params[:army][:confirm] == 'IMPORT'
        uploaded_file = params[:army][:file_upload]
        headers = nil
        @errors = []

        if uploaded_file.present?
          File.foreach(uploaded_file.path) do |line|
            if headers.nil?
              headers = line.strip.split(';') # Assuming the columns are comma-separated
              headers = headers.map { |element| element.split(" ")[0] }
            else
              data = line.strip.split(';') # Assuming data is comma-separated
              hash = Hash[headers.zip(data)]

              # Formatting tags correctly
              hash["tags"] = hash["tags"].split(",")

              # Find the army by its 'id'
              army = Army.find_or_initialize_by(id: hash["id"])

              # Adding faction info
              factions = hash.delete('factions') || []
              factions = factions.split(",").map do |faction_name|
                faction = Faction.find_by(name: faction_name)
                if faction
                  faction.id
                else
                  @errors << "(#{army.id}) #{army.name} : #{faction_name} no existe"
                  nil
                end
              end

              army_data = hash.merge('faction_ids' => factions.compact)

              # Update the attributes
              army.attributes = army_data

              # Check if the army is new or not
              @new = 0
              @mod = 0
              if army.new_record?
                @new += 1
              else
                @mod += 1
              end

              # Save the army to the database
              if !army.save
                @errors << "(#{army.id}) #{army.name} : #{army.errors}"
              end
            end
          end
        end

        if @errors.blank?
          format.html { redirect_to armies_url, success: "#{(@new + @mod)} ejércitos importados correctamente. #{@new} han sido creados. #{@mod} ejércitos han sido modificados." }
        else
          message = '<p>' + (@new + @mod).to_s + ' ejércitos han sido importados correctamente.</p>' +
                    '<p>' + @errors.length.to_s + ' ejércitos han fallado al ser creadas.</p>' +
                    '<p>' + @errors.to_s + '</p>'
          format.html { redirect_to armies_url, danger: message }
        end

      else
        format.html { redirect_to armies_url, danger: 'La palabra de validación es incorrecta.' }
      end
    end
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    @attributes = @options["attributes"].sort_by { |_, v| v["sort"] }.to_h
    @tags = @options["tags"].sort_by { |_, v| v["colour"] }.to_h
    if @options.nil?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de ejércitos'
    end
  end

  def set_army
    @army = Army.find(params[:id])
  end

  def set_factions
    @factions = Faction.where(active: true).order(:name).offset(0)
  end

  def set_filters
    if @current_user&.is_master?
      @filter = [ "Ejército", "Estado", "Rasgos", "Posición", "Grupo", "Visibilidad" ]
    else
      @filter = [ "Ejército", "Rasgos", "Posición", "Grupo" ]
    end
  end

  def check_owner
    if !@current_user.is_master?
      if !@current_user.faction.armies.include?(@army)
        flash[:danger] = 'No tienes permisos para editar ese ejército.'
        render js: "window.location='/armies'"
      end
    end
  end

  def army_params
    params.require(:army).permit(
      :name, :status, :position, :group, :region_id, :lord_id, :confirm,
      :visible, :hp, :col0, :col1, :col2, :col3, :col4, :col5, :col6, :col7, :col8, :col9, :notes, faction_ids: [], tags: []
    ).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
    end
  end
end
