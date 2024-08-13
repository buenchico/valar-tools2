class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy]
  before_action :set_options
  before_action :set_factions, only: [:index, :edit, :edit_multiple, :new]
  before_action :army_stats, only: [:index, :get_armies]
  before_action :set_filters, only: [:index]
  before_action :check_player, except: [:get_discourse_armies, :post_discourse_armies]
  before_action :check_master, only: [:destroy, :destroy_multiple]
  before_action :check_owner, only: [:edit, :edit_notes, :update, :edit_multiple, :update_multiple]
  before_action :set_regions, only: [:new, :edit, :edit_multiple]
  skip_before_action :verify_authenticity_token, only: [:post_discourse_armies]

  def index
    @faction = Faction.find_by(id: params[:faction_id])
    if @current_user&.is_master?
      if @faction
        @armies = @faction.armies.where(visible: true).order(:id)
      else
        @faction = @current_user.faction
        @armies = nil
      end
    else
      @faction = @current_user.faction
      @armies = @faction.armies.where(visible: true).order(:id)
    end
  end

  def get_armies
    @faction = Faction.find_by(id: params[:faction_id])
    active_factions = params[:active_factions].split(",")
    @visible = params[:visible]
    active_visibility = params[:active_visibility].split(",")
    @master = Faction.find_by(name: 'master')

    if active_factions.length == 1
      @stats_faction = Faction.find_by(id: active_factions[0])
    else
      @stats_faction = @master
    end

    if @faction
      if @faction.name == 'master'
        @armies = Army.all.where(visible: active_visibility).order(:id)
      else
        @armies = @faction.armies.where(visible: active_visibility).order(:id)
      end
    else
      if active_factions.include?(@master.id.to_s)
        @armies = Army.all.where(visible: @visible)
      else
        @armies = Army.joins(:factions).where(visible: @visible).where(factions: { id: active_factions })
      end
    end

    @army_ids = @armies.pluck(:id)

    respond_to do | format |
      format.js
    end
  end

  def new
    @army = Army.new
  end

  def create
    @army = Army.new(army_params)

    respond_to do |format|
      if @army.save
        flash.now[:success] = t('messages.success.update', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @army.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: 'el ejército', method: 'create' } }
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
    if army_params[:tags].present?
      army_params[:tags] = army_params[:tags].compact.reject(&:empty?).sort.compact.reject(&:empty?).sort
    end
    if !@current_user&.is_master? # modify params if user is not admin
      keys_to_remove = ["tags", "region", "lord", "visible", "hp",
        "col0", "col1", "col2", "col3", "col4", "col5", "col6", "col7", "col8", "col9", "faction_ids"]
        if @army.status == 'inactive'
          keys_to_remove << "status"
        end
    end

    @inline = params[:inline]
    original_title =  @army.name

    respond_to do |format|
      @army.faction_ids_was = @army.faction_ids
      if @army.update(army_params.reject! { |x| keys_to_remove&.include?(x) })
        flash.now[:success] = t('messages.success.update', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @army.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: original_title + " (id: " + @army.id.to_s + ")", method: 'update' } }
      end
    end
  end

  def update_multiple
    @armies = Army.where(id: params[:army_ids])

    army_params_sum = {}
    army_params_tags = {}
    army_params_hash = {}

    if @current_user&.is_master?
      if (params["army"]["hp_change"].blank? == false)
        army_params_hash[:hp] = params["army"]["hp_change"]
      end
      if (params["army"]["hp_sum"].blank? == false)
        army_params_sum[:hp] = params["army"]["hp_sum"]
      end
      (0..9).each do |i|
        if (params["army"]["col#{i}_change"].blank? == false)
          army_params_hash["col#{i}"] = params["army"]["col#{i}_change"]
        end
        if (params["army"]["col#{i}_sum"].blank? == false)
          army_params_sum["col#{i}"] = params["army"]["col#{i}_sum"]
        end
      end
      if (params["army"]["tags_add"].blank? == false)
        army_params_tags[:tags_add] = params["army"]["tags_add"]
      end
        if (params["army"]["tags_remove"].blank? == false)
        army_params_tags[:tags_remove] = params["army"]["tags_remove"]
      end
    end

    army_params.to_hash.each do | key, value |
      unless value.blank?
        if key == "faction_ids"
          if value.reject!(&:empty?).blank?
            nil
          elsif value == "CLEAR"
            army_params_hash[key] = nil
          else
            army_params_hash[key] = value
          end
        end
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
        if @current_user&.is_master? # Checking the user is admin to modify the status
          if (key == "status")
            if @army_status.keys.include?(value.to_s)
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

    @errors_armies = []
    @updated_armies = []
    $aaa = []

    respond_to do |format|
      if params[:army][:confirm] == 'VALIDATE'
        if army_params_hash.empty? && army_params_sum.empty? && army_params_tags.empty?
          format.html { redirect_to armies_url, success: t('messages.multiple.nothing') }
        else
          @armies.each do |army|
            if army_params_sum.empty? == false
              army_params_sum.each do |key, value|
                # Check if the attribute exists in the Army model
                if army.respond_to?(key)
                  old_value = army[key].to_i
                  army_params_hash[key] = (old_value += value.to_i)
                end
              end
            end

            if army_params_tags.empty? == false
              if army_params_tags[:tags_remove].empty? == false
                army_params_hash[:tags] = army[:tags]&.reject! { |tag| army_params_tags[:tags_remove].include?(tag) }
              end

              if army_params_tags[:tags_add].empty? == false
                if army[:tags].nil?
                  army_params_hash[:tags] = army_params_tags[:tags_add]
                else
                  army_params_hash[:tags] = (army[:tags] || []).dup.concat(army_params_tags[:tags_add]).uniq
                end
              end

              army_params_hash[:tags].compact.reject(&:empty?).sort
            end

            army.faction_ids_was = army.faction_ids
            if army.update(army_params_hash)
              @updated_armies << army.name
            else
              @errors_armies << (army.name.to_s + " | " + army.errors.full_messages.join(", "))
            end
          end

          if @errors_armies.length == 0
            flash[:success] = t('messages.multiple.success', model: Army.model_name.human(:count => @updated_armies.length), succeed: ("<br>" + @updated_armies.join("<br>")).html_safe)
            format.html { redirect_to armies_url }
          else
            flash[:danger] = t('messages.multiple.error', model: Army.model_name.human(:count => @errors_armies.length), failed: ("<br>" + @errors_armies.join("<br>") + "<br>").html_safe, succeed: ("<br>" + @updated_armies.join("<br>")).html_safe)
            format.html { redirect_to armies_url }
          end
        end
      else
        format.html { redirect_to armies_url, danger: t('messages.multiple.validation') }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @army.destroy
        flash.now[:danger] = t('messages.success.destroy', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @army.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: @army.name.strip + " (id: " + @army.id.to_s + ")", method: 'delete' } }
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
        format.html { redirect_to armies_url, danger: t('messages.multiple.validation') }
      end
    end
  end

  def export
    @armies = Army.all

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"armies.csv\""
        headers['Content-Type'] ||= 'text/csv'

        header_row = ["id", "name", "status", "position", "group", "factions", "hp *(#{@options["hp"]["step"]})", "hp_start", "tags", "location", "family"] # Adjust the attributes as needed
        @attributes.each do | key, value |
          header_row << "col#{value['sort']} #{key} *(#{value["str"]})"
        end

        csv_data = CSV.generate(col_sep: ";", headers: true) do |csv|
          csv << header_row # Adjust the attributes as needed

          @armies.each do |army|
            data_row = [army.id, army.name, army.status, army.position, army.group, army.factions.pluck(:name).join(","), army.hp, army.hp_start, army.tags.join(","), army.location&.name, army.family&.title]
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

  def post_discourse_armies
    require 'json'

    # Read the content of the request body
    request_body = request.body.read

    # Parse the JSON content
    json_data = JSON.parse(request_body)

    request_signature = request.headers['x-discourse-event-signature']
    # Your secret configured in Discourse
    discourse_secret = ENV['DISCOURSE_WEBHOOK_SECRET'] # Make sure to set this in your environment variables
    computed_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), discourse_secret, request_signature)

    if discourse_secret = computed_signature
      raw = json_data["post"]["raw"]

      if raw.include?("$army.") && !raw.match(/(`.*?`|^ {4,}.*)/m).present? # Find $army text but ignore if there is code in the message
        match_data = raw.match(/\$army\.(\w+)/)
        if match_data
          group = match_data[1]
          text_to_replace = "$army." + group

          post_id = json_data["post"]["id"]
          username = json_data["post"]["username"]

          faction_id = User.find_by(player: username).faction.id

          replacement_text = get_discourse_armies(faction_id,group)

          raw = json_data["post"]["raw"].gsub(text_to_replace, replacement_text)
          edit_reason = "Ejércitos editados por las tools"

          DiscourseApi::DiscoursePostData.post_armies_data(post_id, raw, edit_reason)
          head :ok
        end
      else
        head :not_modified
      end
    else
      head :unauthorized
    end
  end

  def get_discourse_armies(faction_id, group)
    faction = Faction.find(faction_id)
    armies = faction.armies.where(group: group).where(visible: true)
    armies_text = ""
    armies.each do | army |
      armies_text << "> * "
      armies_text << army.name
      armies_text << " (" + @army_status[army.status]["name"] + ")"
      if army.position.present?
        armies_text << ", " + army.position
      end
      armies_text << " grupo " + ARMY_GROUPS[army.group.to_sym][:name].upcase
      tags = []
      if army.hp != 100
        tags << @options["hp"]["name"].capitalize + " " + number_to_modifier(((army.hp - 100) / @options["hp"]["step"]))
      end
      @attributes.each do | key, value |
        if army["col#{value['sort']}"]&.nonzero?
          tags << value["name"].capitalize + " " + number_to_modifier(army["col#{value['sort']}"])
        end
      end
      if army.tags.present?
        army.tags.each do | tag |
          if @tags[tag]
            tags << @tags[tag]["name"].capitalize
          else
            tags << tag.capitalize
          end
        end
      end
      if tags.present?
        armies_text << " [" + tags.join(", ") + "]"
      end
      armies_text << " FUE: " + army.strength.to_s + "\n"
    end

    if armies_text.empty?
      render plain: "No hay ejércitos en el grupo " + group
    else
      armies_text << "<small>Editado por las tools, grupo **" + ARMY_GROUPS[group.to_sym][:name].upcase + "**</small>\n"
      render plain: armies_text
    end
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    if @options.blank?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de ejércitos'
    else
      @attributes = @options["attributes"]&.sort_by { |_, v| v["sort"] }.to_h
      @men = @options["men"]&.sort_by { |_, v| v["sort"] }.to_h
      @tags = @options["tags"]&.sort_by { |key, _value| key }.to_h
      @army_status = @options["status"]
      @army_types = @options["army_type"]&.sort_by { |_, v| v["sort"] }.to_h
    end
  end

  def set_army
    @army = Army.find(params[:id])
  end

  def set_factions
    @factions = Faction.where.not(name: ['admin','player']).where(active: true).order(:id)
  end

  def set_filters
    if @current_user&.is_master?
      @filter = [ "Ejército", "Estado", "Rasgos", "Posición", "Grupo", "Visibilidad" ]
    else
      @filter = [ "Ejército", "Rasgos", "Posición", "Grupo" ]
    end
  end

  def army_stats
    all_armies = Army.where(visible: true).order(:id)
    @armies_total = all_armies.length
    @men_total = all_armies.sum { |army| ( army.hp.to_i * @options["soldiers"].to_i / 100 ) }
    @str_total = all_armies.sum { |army| army.strength }
    @raised = all_armies.where(status: 'raised').length
    @dead = all_armies.where(status: 'inactive').length
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
            format.html { redirect_to armies_url, danger: t('messages.multiple.permissions', model: Army.model_name.human(:count => 1).downcase) }
            format.js do
              flash[:danger] = t('messages.multiple.permissions', model: Army.model_name.human(:count => 1).downcase)
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
      :visible, :hp, :army_type, :men1, :men2, :men3, :men4, :men5, :men6, :men7, :men8, :men9, :attr0, :attr1, :attr2, :attr3, :attr4, :attr5, :attr6, :attr7, :attr8, :attr9, :notes, :board, faction_ids: [], tags: []
    ).tap do |whitelisted|
      whitelisted[:tags].reject!(&:empty?) if whitelisted[:tags]
      whitelisted[:board] = nil if whitelisted[:board].blank?
    end
  end
end
