class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_current_user

  helper_method :active_game
  helper_method :player_tools
  helper_method :master_tools
  helper_method :admin_tools
  helper_method :inactive_tools

  helper_method :number_to_modifier
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

  def set_tool
    @tool = Tool.find_by(name: controller_name)
  end

  def set_regions
    @regions = Location.where(location_type: "region").where(game_id: active_game.id).order('name_es')
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

  def number_to_modifier(number)
    if number.nil?
      "–"
    elsif number >= 0
      "+#{number}"
    else
      "–#{number.abs}"
    end
  end

  def army_size_mod(number)
    ((-1 + Math.sqrt(1 + 8 * number)) / 2).floor
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
    @attributes = @options_armies["attributes"]&.sort_by { |_, v| v["sort"] }.to_h
    @men = @options_armies["men"]&.sort_by { |_, v| v["sort"] }.to_h
    @tags = @options_armies["tags"]&.sort_by { |key, _value| key }.to_h
    @army_status = @options_armies["status"]
    @army_types = @options_armies["army_type"]&.sort_by { |_, v| v["sort"] }.to_h
    @hp = @options_armies["hp"]
    @fleets = @options_armies["fleets"]
  end

  def set_options_clocks
    @sizes = @options_clocks["sizes"]
    @outcomes = @options_clocks["outcomes"]
    @styles = @options_clocks["styles"]
  end

  def set_options_families
    # No per attribute options
  end

  def set_options_locations
    @location_types = @options_locations["types"]
  end

  def set_options_missions
    @sections = @options_missions["sections"]
  end
end
