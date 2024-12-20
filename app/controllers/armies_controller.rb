class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :edit_notes, :update, :destroy, :show]
  before_action :set_options
  before_action :set_factions, only: [:index, :edit, :edit_multiple, :new, :stats]
  before_action :army_stats, only: [:index, :get_armies]
  before_action :set_filters, only: [:index]
  before_action :check_player, except: [:get_discourse_armies, :post_discourse_armies]
  before_action :check_master, only: [:destroy, :destroy_multiple, :stats]
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

  def show
  end

  def get_armies
    origin = URI(request.referer).path.split('/')[1]
    stats = params[:stats]
    @faction = Faction.find_by(id: params[:faction_id])
    active_factions = JSON.parse(params[:active_factions])
    @visible = params[:visible]
    active_visibility = params[:active_visibility].split(",")
    group = params[:group]
    @checkboxes = params[:checkboxes]
    @master = Faction.find_by(name: 'master')

    if stats
      if active_factions.length == 1
        @stats_faction = Faction.find_by(id: active_factions[0])
      else
        @stats_faction = @master
      end
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

    if group.present?
      @armies = @armies.where(group: group)
    end

    @army_ids = @armies.pluck(:id)

    respond_to do |format|
      format.js do
        if origin.present?
          render "#{origin}/get_armies" # Render the JS template based on the origin
        else
          render js: "alert('Invalid referer');" # Handle cases where origin is nil or empty
        end
      end
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
    army_ids = params[:army_ids].split(',')
    @armies = Army.where(id: army_ids).order(:name)
    @action = params[:button]
  end

  def update
    puts army_params
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

    @inline = inline_param # Set the inline variable based on the parameter
    original_title =  @army.name

    respond_to do |format|
      @army.faction_ids_was = @army.faction_ids
      if @army.update(army_params.reject! { |x| keys_to_remove&.include?(x) })
        if @inline == true
          @toast = t('messages.success.update', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        else
          flash.now[:success] = t('messages.success.update', thing: @army.name.strip + " (id: " + @army.id.to_s + ")", count: 1)
        end
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
        if (params["army"]["attr#{i}_change"].blank? == false)
          army_params_hash["attr#{i}"] = params["army"]["attr#{i}_change"]
        end
        if (params["army"]["attr#{i}_sum"].blank? == false)
          army_params_sum["attr#{i}"] = params["army"]["attr#{i}_sum"]
        end
      end
      (1..9).each do |i|
        if (params["army"]["men#{i}_change"].blank? == false)
          army_params_hash["men#{i}"] = params["army"]["men#{i}_change"]
        end
        if (params["army"]["men#{i}_sum"].blank? == false)
          army_params_sum["men#{i}"] = params["army"]["men#{i}_sum"]
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
        if key == "group"
          if value == "CLEAR"
            army_params_hash[key] = nil
          else (ARMY_GROUPS.keys.map { |k| k.to_s }).include?(value.to_s)
            army_params_hash[key] = value
          end
        end
        if @current_user&.is_master? # Checking the user is admin to modify the status
          if key == "status"
            if @army_status.keys.include?(value.to_s)
              army_params_hash[key] = value
            end
          end
          if key == "army_type"
            if value == "CLEAR"
              army_params_hash[key] = nil
            else
              army_params_hash[key] = value
            end
          end
          if key == "location_id"
            if value == "CLEAR"
              army_params_hash[key] = nil
            else
              army_params_hash[key] = value
            end
          end
          if key == "family_id"
            if value == "CLEAR"
              army_params_hash[key] = nil
            else
              army_params_hash[key] = value
            end
          end
          if key == "visible"
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

        header_row = ["id", "name", "status", "position", "group", "factions", "hp *(#{@options["hp"]["step"]})", "hp_start", "army_type", "tags", "location", "family"] # Adjust the attributes as needed
        @attributes.each do | key, value |
          header_row << "attr#{value['sort']} #{key} *(#{value["attr"]})"
        end
        @men.each do | key, value |
          header_row << "men#{value['sort']} #{key} *(#{value["men"]})"
        end

        csv_data = CSV.generate(col_sep: ";", headers: true) do |csv|
          csv << header_row # Adjust the attributes as needed

          @armies.each do |army|
            data_row = [army.id, army.name, army.status, army.position, army.group, army.factions.pluck(:name).join(","), army.hp, army.hp_start, army.army_type, army.tags.join(","), army.location&.name, army.family&.title]
            @attributes.each do | key, value |
              data_row << army["attr#{value['sort']}"]
            end
            @men.each do | key, value |
              data_row << army["men#{value['sort']}"]
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
        @errors = {}
        @new = 0
        @mod = 0
        @failed = 0

        if uploaded_file.present?
          File.foreach(uploaded_file.path) do |line|
            if headers.nil?
              headers = line.strip.split(';') # Assuming the columns are comma-separated
              headers = headers.map { |element| element.split(" ")[0] }
            else
              data = line.strip.split(';') # Assuming data is comma-separated
              hash = Hash[headers.zip(data)]

              # Formatting tags correctly
              hash["tags"] = (hash["tags"] || "").split(",")

              # Find the army by its 'id'
              army = Army.find_or_initialize_by(id: hash["id"])

              # Adding faction info
              factions = hash.delete('factions') || []
              factions = factions.split(",").map do |faction_name|
                faction = Faction.find_by(name: faction_name)
                if faction
                  faction.id
                else
                  @errors[army.name] ||= []
                  @errors[army.name] << ("la facción #{faction_name} no existe")
                end
              end

              # Checking visibility
              hash["visible"] ||= false

              # Adding location and family info
              location_name = hash.delete('location')
              if location_name.nil?
                hash["location_id"] = nil
              else
                location = Location.where(location_type: "region").search_by_name(location_name).first
                if location
                  hash["location_id"] = location.id
                else
                  @errors[army.name] ||= []
                  @errors[army.name] << ("la región #{location_name} no existe")
                end
              end

              family_title = hash.delete('family')

              if family_title.nil?
                hash["family_id"] = nil
              else
                # Initialize family_name and family_branch variables
                family_name = ""
                family_branch = ""

                # Use a regular expression to match the pattern
                match = family_title.match(/^(.*?)\s?\((.*?)\)$/)

                if match
                  family_name = match[1]
                  family_branch = match[2]
                else
                  # If the pattern doesn't match, assume the entire string is the family_name
                  family_name = family_title
                end

                if family_branch.nil?
                  family = Family.find_by(name: family_name)
                else
                  family = Family.where(name: family_name).find_by(branch: family_branch)
                end

                if family
                  hash["family_id"] = family.id
                else
                  @errors[army.name] ||= []
                  @errors[army.name] << ("la familia #{family_title} no existe")
                end
              end

              army_data = hash.merge('faction_ids' => factions.compact)

              # Update the attributes
                  army.attributes = army_data

              # Check if the army is new or not
              if army.new_record?
                @new += 1
              else
                @mod += 1
              end

              # Save the army to the database
              if army.save
                nil
              else
                @failed += 1
                @errors[army.name] ||= []
                @errors[army.name] << ("#{army.errors.full_messages}")
              end
            end
          end
        end

        if @errors.blank?
          format.html { redirect_to armies_url, success: "#{(@new + @mod)} ejércitos importados correctamente. #{@new} han sido creados. #{@mod} ejércitos han sido modificados." }
        else
          errors_message = ''
          @errors.each do | key, value |
            errors_message += '<p>' + key.to_s + " " + value.to_s + '</p>'
          end

          message = '<p>' + (@new + @mod).to_s + ' ejércitos han sido importados correctamente.</p>' +
                    '<p>' + @failed.to_s + ' ejércitos han fallado al ser creadas.</p>' +
                    errors_message
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
      traits = []
      ((100 - army.hp) / @hp["step"])&.nonzero? ? traits << (@hp["name"].capitalize + " " + number_to_modifier(((army.hp - 100) / @hp["step"]))).html_safe : nil
      traits << @army_types.fetch(army.army_type, {}).fetch("name", army.army_type).capitalize
      @men.each do | key, value |
        if value["sort"] != 0
          (army["men#{value['sort']}"]&.nonzero? ? traits << (value["name"].capitalize + " " + number_to_modifier(army["men#{value['sort']}"])).html_safe : nil )
        end
      end
      @attributes.each do | key, value |
        (army["attr#{value['sort']}"]&.nonzero? ? traits << (value["name"].capitalize + " " + number_to_modifier(army["attr#{value['sort']}"])).html_safe : nil )
      end
      if army.tags.present?
        army.tags.each do | tag |
          if @tags[tag]
            traits << @tags[tag]["name"].capitalize
          else
            traits << tag.capitalize
          end
        end
      end
      armies_text << " [" + traits.join(", ") + "] "
      armies_text << " FUE: " + army.strength.to_s + "\n"
    end

    if armies_text.empty?
      render plain: "No hay ejércitos en el grupo " + group
    else
      armies_text << "<small>Editado por las tools, grupo **" + ARMY_GROUPS[group.to_sym][:name].upcase + "**</small>\n"
      render plain: armies_text
    end
  end

  def stats
    @armies = Army.all
  end

private
  def set_options
    @options_armies = get_options(@tool)
    if @options_armies.blank?
      redirect_to settings_url, warning: t('activerecord.errors.messages.options_not_ready', tool_name: @tool.title)
    else
      set_options_armies
    end
  end

  def set_army
    @army = Army.find(params[:id])
  end

  def set_factions
    @factions = Faction.where.not(name: ['admin','player']).where(active: true).order(:id)
  end

  def set_filters
    @filter = [ t('activerecord.attributes.army.selected'), t('activerecord.attributes.army.name'), t('activerecord.attributes.army.status'), t('activerecord.attributes.army.traits'), t('activerecord.attributes.army.position'), t('activerecord.attributes.army.group') ]
    if @current_user&.is_master?
        @filter << t('activerecord.attributes.army.visible')
    end
  end

  def army_stats
    all_armies = Army.where(visible: true).order(:id)
    @armies_total = all_armies.length
    @men_total = all_armies.sum { |army| army.men }
    @str_total = all_armies.sum { |army| army.strength }.round(2)
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
      whitelisted[:board] = nil if whitelisted.key?(:board) && whitelisted[:board].blank?
    end
  end

  # Use a separate method to handle the `inline` parameter for logic purposes
  def inline_param
    params.dig(:army, :inline) == "true"
  end
end
