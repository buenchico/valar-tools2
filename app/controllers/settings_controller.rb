class SettingsController < ApplicationController
  before_action :check_admin

  def index
    @active_game = active_game
    @tool = Tool.find_by(name: controller_name)
    @games = Game.all.order(:id)
    @tools = Tool.all.order(:sort).order(:id)
  end
end
