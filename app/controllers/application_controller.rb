class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_current_user

  helper_method :active_game
  helper_method :player_tools
  helper_method :master_tools
  helper_method :admin_tools
  helper_method :inactive_tools

  helper_method :army_size_mod

  add_flash_types :error, :success, :info, :danger, :warning

  def set_current_user
    @current_user ||= User.find_by(auth_token: cookies[:auth_token]) if cookies[:auth_token]
    Thread.current[:current_user] = @current_user
  end

  def active_game
    active_game ||= Game.find_by(active: true)
  end

  def check_player
    # allows only logged in user
    if @current_user.nil?
      respond_to do |format|
        format.html { redirect_to root_path, danger: 'No tienes permisos para acceder a esta herramienta' }
        format.js do
          flash[:danger] = 'No tienes permisos para acceder a esta herramienta'
          render js: 'window.location.replace("/");'
        end
      end
    end
  end

  def check_admin
    # allows only admin user
    if @current_user.nil? || !@current_user.is_admin?
      respond_to do |format|
        format.html { redirect_to root_path, danger: 'No tienes permisos para acceder a esta herramienta' }
        format.js do
          flash[:danger] = 'No tienes permisos para acceder a esta herramienta'
          render js: 'window.location.replace("/");'
        end
      end
    end
  end

  def check_master
    # allows only master user
    if @current_user.nil? || !@current_user.is_master?
      respond_to do |format|
        format.html { redirect_to root_path, danger: 'No tienes permisos para acceder a esta herramienta' }
        format.js do
          flash[:danger] = 'No tienes permisos para acceder a esta herramienta'
          render js: 'window.location.replace("/");'
        end
      end
    end
  end

  def army_size_mod(number)
    @army_scale = 5000
    if number >= (@army_scale * 10)
      number = (number / (@army_scale * 10))
    else
      number = 0
    end
    ((-1 + Math.sqrt(1 + 8 * number)) / 2).floor
  end

  def sorted_hash(hash, *keys)
    return {} unless hash.is_a?(Hash)

    hash.sort_by do |_, v|
      keys.map { |k| v[k] || 99 }
    end.to_h
  end

  def set_tool
    @tool = Tool.find_by(name: controller_name)
  end

  def set_families
    if @current_user&.is_master?
      @families = Family.where(game_id: active_game.id).order(:name)
    else
      @families = Family.where(visible: true).where(game_id: active_game.id).order(:name)
    end
  end

  def player_tools
    if @current_user&.is_master?
      player_tools = Tool.where(active: true).where(role: ['player', 'guest'])
    else
      player_tools = active_game&.tools&.where(active: true)&.where(role:['player', 'guest'])
    end
  end

  def master_tools
    master_tools = Tool.where(active: true).where(role:'master')
  end

  def admin_tools
    admin_tools = Tool.where(active: true).where(role:'admin')
  end

  def inactive_tools
    inactive_tools = Tool.where(active: false)
  end

  def generate_pseudorandom_id
    timestamp = Time.now.to_i
    random_hex = SecureRandom.hex(4) # You can adjust the length of the random part as needed.
    pseudorandom_id = "#{timestamp}_#{random_hex}"
    return pseudorandom_id
  end

  def set_factions
    @factions = Faction.where.not(name: ['admin','player']).where(active: true).order(:id)
  end

  def get_options(tool)
    tool.game_tools.find_by(game_id: active_game&.id)&.options
  end

  def set_options_armies(options)
    @options_armies = options[:armies]
    @options_locations = options[:locations]

    @army_speeds = options[:travel].fetch("speed", {})

    @army_types = sorted_hash(@options_armies["army_type"], "sort")
    @army_status = @options_armies["status"]

    @army_tags = sorted_hash(@options_armies["army_tags"], "sort", "name")
    @unit_types = sorted_hash(@options_armies["units"], "type", "sort", "name")
    @unit_tags = sorted_hash(@options_armies["unit_tags"], "sort", "name")

    general = @options_armies["general"] || {}
    @army_scale = general["scale"]
    @army_xp = general["xp"]
    @army_morale = general["morale"]

    locations = Location.where(game_id: active_game.id)

    @population_total = locations.sum { |loc| loc.population.to_i }
    @population_start = locations.sum { |loc| loc.population_start.to_i }
    @population_dead = (@population_start - @population_total)

    @regions = @options_locations.fetch("region_types", ["region"]).flat_map do |type|
      locations.where(location_type: type).order(:name_es)
            end
  end

  def set_options_locations(options)
    @options_locations = options[:locations]
    @location_types = @options_locations["types"]
    @population_types = @options_locations.fetch("population", {}).fetch("types_with_population", [])
    @regions = @options_locations.fetch("region_types", ["region"]).flat_map do |type|
      Location.where(location_type: type, game_id: active_game.id)
              .order(:name_es)
            end
  end

  def set_options_clocks(options)
    @options_clocks = options[:clocks]
    @sizes = @options_clocks["sizes"]
    @outcomes = @options_clocks["outcomes"]
    @styles = @options_clocks["styles"]
  end

  def set_options_families(options)
    @options_families = options[:families]

    @options_families["subtools"] ||= {}

    @options_families["subtools"]["tags"] = true if @options_families["tags"].present?
    @options_families["subtools"]["loyalties"] = true if @options_families["loyalties"].present?
    @options_families["subtools"]["tiers"] = true if @options_families["tiers"].present?
    @options_families["subtools"]["armies"] = true if Tool.find_by(name: "armies").is_active?
  end

  def set_options_missions(options)
    @options_missions = options[:missions]

    @sections = @options_missions["sections"]
  end

  def set_options_factions(options)
    @options_factions = options[:factions]
  end

  def set_options_map(options)
    @options_map = options[:map]
  end

  def set_options_travel(options)
    @options_travel = options[:travel]

    @terrain = @options_travel["terrain"]
    @speed = @options_travel["speed"]
    @obstacles = @options_travel["obstacles"]
  end

  def set_options_settings(options)
    @options_settings = options[:settings]
    @workdays = @options_settings["workdays"]
  end
end
