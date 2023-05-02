class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :active_game
  helper_method :user_roles
  helper_method :player_tools
  helper_method :master_tools
  helper_method :admin_tools
  helper_method :inactive_tools

  add_flash_types :error, :success, :info, :danger

  def current_user
    current_user ||= User.find_by(auth_token: cookies[:auth_token]) if cookies[:auth_token]
  end

  def active_game
    active_game ||= Game.find_by(active: true)
  end

  def check_admin
    # allows only logged in user
    if current_user.nil? || !current_user.is_admin?
      flash[:danger] = 'No tienes permisos para acceder a esta herramienta'
      redirect_to root_path
    end
  end

  def check_master
    # allows only logged in user
    if current_user.nil? || !current_user.is_master?
      flash[:danger] = 'No tienes permisos para acceder a esta herramienta'
      redirect_to root_path
    end
  end

  def set_user_roles
    user_roles = ['player', 'master', 'admin']
  end

  def player_tools
    player_tools = Tool.where(active: true).where(role:'player')
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
end
