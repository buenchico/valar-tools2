class SettingsController < ApplicationController
  def index
    @tool = Tool.find_by(name: controller_name)

    @games = Game.all.order(:id)
    @tools = Tool.all.order(:sort).order(:id)
  end
end
