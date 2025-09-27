class TravelController < ApplicationController
  before_action :set_tool, only: [:index, :calculate]
  before_action :set_options, only: [:index, :calculate]

  def index
  end

  def calculate

    @from = params[:from] != "" ? params[:from] : "Origen"
    @to = params[:to] != "" ? params[:to] : "Destino"
    @size = params[:size].to_f
    size_mod = params[:size_mod].to_f

    #get travel data
    base = @options_travel["base"] # hours per hexagon
    size_time = size_mod / 100.0

    steps = params[:step].nil? ? 0 : params[:step]

    time = 0
    @steps = []
    steps.each do | index, step |
      hex = step["hex"].to_i
      if hex > 0
        terrain_name = JSON.parse(step["terrain"])[0]
        terrain = JSON.parse(step["terrain"])[1]

        speed_name = JSON.parse(step["speed"])[0]
        speed = JSON.parse(step["speed"])[1]

        modifier = (terrain * speed)

        if step["obstacle"].blank?
          obstacle_name = ""
          obstacle = 0
        else
          obstacle_name = JSON(step["obstacle"])[0]
          obstacle = JSON(step["obstacle"])[1]
        end

        step_time = (hex * base * size_time * modifier).round + (obstacle * base * size_time).round # in hours

        time += step_time
        line = { hex: hex, step_time: step_time, terrain_name: terrain_name, speed_name: speed_name, obstacle_name: obstacle_name }
        puts line
        @steps << line
      end
    end

    @time = time
    @travel_time = travel_time(time)

    respond_to :js
  end

private
  def set_options
    options = GameOptionsService.fetch

    if options[:armies].blank?
      redirect_to settings_url, warning: t('activerecord.errors.messages.options_not_ready', tool_name: @tool.title)
    else
      set_options_travel(options)
    end
  end

  def travel_time(time)
    options = {
      scope: :'datetime.distance_in_words'
    }

    phase_shift = 3
    adjusted_time = [(time + phase_shift),0].max

    half_days = adjusted_time / 12

    weeks = half_days / ( 5 * 2 ) # Using 5 days weeks
    days = ( half_days - ( weeks * 5 * 2 ) ) / 2
    half =

    I18n.with_options scope: options[:scope] do |locale|
      message = ""
      if weeks != 0
        message += locale.t :x_weeks, count: weeks
      end

      if days != 0
        if weeks != 0
          message += " #{I18n.t('and')} "
        end
        message += locale.t :x_days, count: days
      end

      if (half_days <= 1 || half_days.odd?)
        message += locale.t :x_half_days, count: half_days
      end

      return message
    end
  end
end
