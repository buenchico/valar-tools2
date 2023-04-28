class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :active_game
  add_flash_types :error, :success, :info, :danger
  before_action :set_user_roles

  def current_user
    current_user ||= User.find_by(auth_token: cookies[:auth_token]) if cookies[:auth_token]
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

  def active_game
    @active_game ||= Game.find_by(active: true)
  end

  def set_user_roles
    @user_roles = ['player', 'master', 'admin']
  end
end
