class TravelController < ApplicationController
  before_action :set_tool, only: [:index, :calculate]
  before_action :set_options, only: [:index, :calculate]

  def index
  end

  def calculate
    #get data from the form
    terrain_type = params[:type]

    @from = params[:from] != "" ? params[:from] : "Origen"
    @to = params[:to] != "" ? params[:to] : "Destino"
    size = params[:size].to_i

    army_speed = JSON.parse(params[:army_speed][terrain_type])

    steps = params[:step].nil? ? 0 : params[:step].to_unsafe_h

    #get travel data
    base = @options[terrain_type]["base"] # hours per hexagon

    size_table = @options["size"].sort_by { |item| -item[0] }

    size_table.each do |threshold, modifier|
      if size > threshold
        @size_mod = modifier
        break
      end
    end

    @time = 0
    @message = []
    steps.each do | index, step |
      line = ""
      hex = step["hex"].to_i
      if hex > 0
        terrain = JSON.parse(step["terrain"][terrain_type])
        speed = JSON.parse(step["travel_speed"])
        obstacle = step["obstacle"][terrain_type].blank? ? "" : JSON(step["obstacle"][terrain_type])
        step_time = hex * ( base.to_i + @size_mod.to_i + army_speed[1].to_i + terrain[1].to_i + speed[1].to_i) + obstacle[1].to_i
        @time += step_time
        line << "<p class='ms-2'>#{hex} #{t('hexagon', count: hex)} de #{terrain[0].downcase}, a marcha #{speed[0].downcase}"
        obstacle.blank? ? nil : line << ", cruzando un #{obstacle[0].downcase},"
        line << " en #{step_time} #{t('hours', count: step_time)}</p>"
        @message << line
      end
    end

    count = [size, 1].min

    if terrain_type == "land"
      @html = "<p>Un #{Army.model_name.human(:count => count).downcase} "
    else
      @html = "<p>Una #{I18n.t("fleet", count: count).downcase}"
    end

    @html += ((size == 0) ? "" : " de tamaño #{size}")

    @html += " necesita #{travel_time(@time)} para ir desde #{@from} hasta #{@to}</p>"

    @message.each do | line |
      @html += line
    end

    respond_to :js
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game.id).options

    if @options.nil?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la calculadora de rutas'
    end
  end

  def travel_time(time)
    options = {
      scope: :'datetime.distance_in_words'
    }
    weeks = time / ( 24 * 5 ) # using 5 days weeks
    days = (time % ( 24 * 5 ) / 24)
    hours = (time % ( 24 * 5 ) % 24)

    I18n.with_options scope: options[:scope] do |locale|
      message = ""
      if weeks != 0
        message += locale.t :x_weeks, count: weeks
      end

      if days != 0
        if !weeks.zero?
          if hours != 0
            message += ","
          else
            message += " #{I18n.t('and')}"
          end
        end
        message += " #{locale.t :x_days, count: days}"
      end

      if hours != 0
        if (!weeks.zero? || !days.zero?)
          message += " #{I18n.t('and')}"
        end
        message += " #{locale.t :x_hours, count: hours}"
      end

      return message
    end
  end
end
