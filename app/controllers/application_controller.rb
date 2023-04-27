class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :active_game
  add_flash_types :error, :success, :info, :danger
  before_action :set_user_roles

  def current_user
      @current_user ||= User.where("auth_token = ?", cookies[:auth_token]).first if cookies[:auth_token]
  end

  def active_game
    @active_game ||= Game.find_by(active: true)
  end

  def set_user_roles
    @user_roles = ['player', 'master', 'admin']
  end
end
