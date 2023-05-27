class MapController < ApplicationController
  before_action :set_tool
  before_action :set_options

  def index
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
  end
end
