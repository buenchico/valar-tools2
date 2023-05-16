class SettingsController < ApplicationController
  before_action :check_admin
  before_action :set_tool

  def index
    @active_game = active_game
    @games = Game.all.order(:id)
    @tools = Tool.all.order(:sort).order(:id)
  end
end
