class MapController < ApplicationController
  before_action :set_tool
  before_action :set_options
  before_action :set_locations_list

  def index
  end

  def show
    @location = Location.find(params[:id])
  end

private
  def set_options
    options = GameOptionsService.fetch

    if options[:map].blank?
      redirect_to settings_url, warning: t('activerecord.errors.messages.options_not_ready', tool_name: @tool.title)
    else
      set_options_map(options)
      set_options_locations(options)
    end
  end

  def set_locations_list
    @locations = active_game.locations.where(visible: true)
  end
end
