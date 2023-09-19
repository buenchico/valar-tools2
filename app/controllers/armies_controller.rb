class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy]
  before_action :set_options, only: [:index, :edit, :edit_multiple, :update, :new, :export]
  before_action :set_factions, only: [:edit, :new]
  before_action :set_filters, only: [:index]
  before_action :check_player
  before_action :check_master, only: [:destroy, :destroy_multiple]
  before_action :check_owner, only: [:edit, :edit_notes, :update, :edit_multiple, :update_multiple]
  before_action :set_regions, only: [:new, :edit, :edit_multiple]

  def index
    @factions = Faction.where(active: true).order(:id).drop(1)
    @all_armies = Army.all.order(:id)
    if !@current_user&.is_master?
      @armies = @current_user.faction.armies.where(visible: true).order(:id)
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
  end

  def update
    puts params

  end

  def update_multiple
    @armies = Army.where(id: params[:army_ids])

    army_params_hash = {}
    army_params.to_hash.each do | key, value |
      unless value.blank?
        if key == "board"
          if value == "CLEAR"
            army_params_hash[key] = nil
          else
            army_params_hash[key] = value
          end
        end
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
        if @current_user&.is_admin? # Checking the user is admin to modify the status
          if (key == "status")
            if ARMY_STATUS.include?(value.to_s)
              army_params_hash[key] = value
            end
          end
          if (key == "location_id")
            if value == "CLEAR"
              army_params_hash[key] = nil
            else
              army_params_hash[key] = value
            end
          end
          if (key == "family_id")
            if value == "CLEAR"
              army_params_hash[key] = nil
            else
              army_params_hash[key] = value
            end
          end
          if (key == "visible")
            if value == "CLEAR"
              army_params_hash[key] = nil
            else
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
        if @armies.each { |army| army.factions.clear } && @armies.destroy_all
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

        header_row = ["id", "name", "status", "position", "group", "factions", "hp *(#{@options["hp"]["step"]})", "tags", "location", "family"] # Adjust the attributes as needed
        @attributes.each do | key, value |
          header_row << "col#{value['sort']} #{key} *(#{value["str"]})"
        end

        csv_data = CSV.generate(col_sep: ";", headers: true) do |csv|
          csv << header_row # Adjust the attributes as needed

          @armies.each do |army|
            data_row = [army.id, army.name, army.status, army.position, army.group, army.factions.pluck(:name).join(","), army.hp, army.tags.join(","), army.location&.name, army.family&.title]
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
                  @errors << "(#{army.id}) #{army.name} : la facción no existe"
                  nil
                end
              end

              # Adding location and family info
              location = hash.delete('location')
              if location.nil?
                hash["location_id"] = nil
              else
                location = Location.where(location_type: "region").search_by_name(location).first
                if location
                  hash["location_id"] = location.id
                else
                  @errors << "(#{army.id}) #{army.name} : la región no existe"
                  nil
                end
              end

              family = hash.delete('family')

              if family.nil?
                hash["family_id"] = nil
              else
                # Initialize family_name and family_branch variables
                family_name = ""
                family_branch = ""

                # Use a regular expression to match the pattern
                match = family.match(/^(.*?)\s?\((.*?)\)$/)

                if match
                  family_name = match[1]
                  family_branch = match[2]
                else
                  # If the pattern doesn't match, assume the entire string is the family_name
                  family_name = family
                end
                family = Family.where(name: family_name).find_by(branch: family_branch)
                if family
                  hash["family_id"] = family.id
                else
                  @errors << "(#{army.id}) #{army.name} : la familia no existe"
                  nil
                end
              end

              army_data = hash.merge('faction_ids' => factions.compact)

              puts army_data

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
    if @options.blank?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de ejércitos'
    else
      @attributes = @options["attributes"]&.sort_by { |_, v| v["sort"] }.to_h
      @tags = @options["tags"]&.sort_by { |_, v| v["colour"] }.to_h
      $options_armies = @options
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
    armies_to_include = [@army] # Initialize with @army

    if params[:army_ids].present?
      armies_to_include += Army.where(id: params[:army_ids]).order(:name)
    end

    if !@current_user&.is_master?
      armies_to_include.compact.each do |army|
        if !@current_user.faction.armies.include?(army)
          respond_to do |format|
            format.html { redirect_to armies_url, danger: 'No tienes permisos para editar ese ejército.' }
            format.js do
              flash[:danger] = 'No tienes permisos para editar ese ejército.'
              render js: "window.location='/armies'"
            end
          end
        end
      end
    end
  end

  def army_params
    params.require(:army).permit(
      :name, :status, :position, :group, :location_id, :family_id, :confirm,
      :visible, :hp, :col0, :col1, :col2, :col3, :col4, :col5, :col6, :col7, :col8, :col9, :notes, :board, faction_ids: [], tags: []
    ).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
      whitelisted[:board] = nil if whitelisted[:board].blank?
    end
  end
end
