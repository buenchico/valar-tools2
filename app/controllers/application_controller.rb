class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_current_user

  helper_method :active_game
  helper_method :player_tools
  helper_method :master_tools
  helper_method :admin_tools
  helper_method :inactive_tools

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

  def set_tool
    @tool = Tool.find_by(name: controller_name)
  end

  def set_regions
    @regions = Location.where(location_type: "region").where(game_id: active_game.id).order('name_es')
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

  def get_options(tool)
    tool.game_tools.find_by(game_id: active_game&.id)&.options
  end

  def set_options_armies
    # @attributes = @options_armies["attributes"]&.sort_by { |_, v| v["sort"] }.to_h
    # @men = @options_armies["men"]&.sort_by { |_, v| v["sort"] }.to_h
    # @army_types = @options_armies["army_type"]&.sort_by { |_, v| v["sort"] }.to_h
    # @hp = @options_armies["hp"]
    # @fleets = @options_armies["fleets"]
    @army_status = @options_armies["status"]
    @army_tags = @options_armies["tags"]&.sort_by do |_, v|
      [v["sort"] || 99, v["name"]]
    end.to_h
    @unit_types = @options_armies["units"]&.sort_by do |_, v|
      [v["sort"] || 99, v["name"]]
    end.to_h
    @army_scale = @options_armies["general"]["scale"]
    @army_xp = @options_armies["general"]["xp"]
    @army_morale = @options_armies["general"]["morale"]
  end

  def set_options_clocks
    @sizes = @options_clocks["sizes"]
    @outcomes = @options_clocks["outcomes"]
    @styles = @options_clocks["styles"]
  end

  def set_options_families
    @options_families["subtools"] ||= {}

    @options_families["subtools"]["tags"] = true if @options_families["tags"].present?
    @options_families["subtools"]["loyalties"] = true if @options_families["loyalties"].present?
    @options_families["subtools"]["tiers"] = true if @options_families["tiers"].present?
    @options_families["subtools"]["armies"] = true if Tool.find_by(name: "armies").is_active?
  end

  def set_options_locations
    @location_types = @options_locations["types"]
  end

  def set_options_missions
    @sections = @options_missions["sections"]
  end
end
