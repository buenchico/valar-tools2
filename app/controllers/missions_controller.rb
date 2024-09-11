class MissionsController < ApplicationController
  before_action :set_tool
  before_action :set_options, only: [:index, :calculate, :get_recipe]
  before_action :check_master, only: [:list]

  def index
    @recipes = Recipe.all.order(:section, :id)
    @default_recipe = Recipe.find_by(id: @options["default_recipe"])
  end

  def get_recipe
    # Check if params[:recipe_id] is present and corresponds to an existing Recipe
    @recipe = if params[:recipe].present?
                Recipe.find_by(id: params[:recipe])
              end

    # If recipe is not found or params[:recipe_id] is empty, initialize a default recipe
    @recipe ||= Recipe.new(
      name: @options["fortune"]["long_name"],
      difficulty: 0,
      speed: 2,
      description: @options["fortune"]["desc"]
    )

    respond_to do |format|
      format.js
    end
  end

  def calculate
    payload = {
      jsonrpc: '2.0',
      method: 'generateIntegers',
      params: {
        apiKey: ENV['RANDOM_ORG_API_KEY'],
        n: 3,
        min: 1,
        max: 10,
        replacement: true
      },
      id: generate_pseudorandom_id
    }

    conn = Faraday.new(url: 'https://api.random.org/json-rpc/4/invoke') do |faraday|
      faraday.request :json
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end

    response = conn.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(payload)
    end

    if response.success?
      dice = response.body['result']['random']['data'].sort
    else
      dice = Array.new(3) { rand(1..10) }.sort
    end

    roll = dice[1]

    @recipe = Recipe.find(params[:recipe_id].to_i)
    speed = params[:speed].to_i
    difficulty = params[:difficulty].to_i
    tokens = params[:tokens].to_i
    advantage = params[:advantage].to_i
    misc = params[:misc].to_i
    role = params[:role].to_i
    fortune = params[:fortune].downcase.in?(['true', 'yes', '1'])
    factors = params[:factors].to_i
    factors_plus_simple = JSON.parse(params[:factors_plus_simple])
    factors_plus_double = JSON.parse(params[:factors_plus_double])
    factors_minus_simple = JSON.parse(params[:factors_minus_simple])
    factors_minus_double = JSON.parse(params[:factors_minus_double])

    factors_list = {plus_simple: simplify_factors(factors_plus_simple), plus_double: simplify_factors(factors_plus_double), minus_simple: simplify_factors(factors_minus_simple), minus_double: simplify_factors(factors_minus_double)}

    if roll == 10
      critic = 5
    elsif roll == 1
      critic = -6
    else
      critic = 0
    end

    roll = roll + critic

    if fortune == true
      subtotal = factors
    else
      subtotal = difficulty + tokens + advantage + misc + role + factors
    end

    total = roll + subtotal

    if fortune == true
      @options["fortune"]["results"].sort.reverse.each do |range|
          if range[0].to_i <= total
            @result = range[1]
            puts range[1]
            break
          end
      end
    else
      @options["results"].sort.reverse.each do |range|
          if range[0].to_i <= total
            @result = range[1]
            break
          end
      end
    end

    @data = {
      dice: dice,
      roll: roll,
      difficulty: difficulty,
      tokens: tokens,
      factors: factors,
      factors_list: factors_list,
      misc: misc,
      role: role,
      subtotal: subtotal,
      total: total,
      speed: speed
    }

    @fortune = fortune
  end

  def list
    factions = Faction.all
    masters_ids = User.where(faction: Faction.find_by(name: 'master')).pluck(:discourse_id)

    date_past = Date.new(2000, 1, 1)
    date_today = Date.today
    date_future = Date.new(3000, 1, 1)

    missions_by_tag = DiscourseApi::DiscourseGetData.get_missions_by_tag('abierta')

    topic_ids = missions_by_tag.map { |topic| topic["id"] }

    @missions = {}

    missions_by_id = DiscourseApi::DiscourseGetData.get_missions_by_id(topic_ids)
    missions_by_id.each do | id, topic |

      color = "row-striped"
      today = nil
      if topic["topic_timer"].present?
        # Timer is present
        date = Date.parse(topic["topic_timer"]["execute_at"])
        # Timer is of incorrect type
        if topic["topic_timer"]["status_type"] != "bump"
          message = t('missions.index.no_bump')
          color = "bg-warning"
        end
      else
        # Timer is not present
        if topic["post_stream"]["posts"].last["action_code"] == "autobumped"
          # Topic has been bumped today
          date = date_today
          today = 'calendar-accent'
        elsif masters_ids.include?(topic["post_stream"]["posts"].last["user_id"]) && topic["post_type"] == 1
          # Last message is a normal message by master
          date = date_future
          message = t('missions.index.awaiting_player')
        else
          # All other cases
          date = date_past
          message = t('missions.index.no_date_long')
        end
      end

      post = topic["post_stream"]["posts"][0]["cooked"]
      match_data = post.match(/Objetivo<\/h2>(.*?)<h2>/m)
      target = match_data ? match_data[1].strip : t('missions.index.no_target')

      category = (factions.find_by(category_id: topic["category_id"])&.long_name || t('activerecord.attributes.faction.no_category'))

      @missions[id] = {
        title: topic["fancy_title"],
        category: category,
        assigned_to: topic.fetch("assigned_to_user", {})&.fetch("username", t('missions.index.no_assigned')),
        date: date,
        target: target,
        message: message,
        color: color,
        today: today
      }
    end

    @missions
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    @sections = @options["sections"]

    if @options.blank?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la calculadora de misiones'
    end
  end

  def simplify_factors(factors)
    counted_factors = factors.group_by { |factor| factor }.transform_values(&:count)

    counted_factors.map do |element, count|
      count > 1 ? "#{count}x #{element}" : element
    end
  end
end
