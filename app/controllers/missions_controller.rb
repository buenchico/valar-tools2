class MissionsController < ApplicationController
  before_action :set_tool
  before_action :set_options, only: [:index, :calculate, :get_recipe, :list, :stats, :set_mission_timer]
  before_action :check_master, only: [:list]

  def index
    @recipes = Recipe.joins(:games).where(games: { id: active_game.id })
    @default_recipe = Recipe.find_by(id: @options_missions["default_recipe"])
  end

  def get_recipe
    # Check if params[:recipe_id] is present and corresponds to an existing Recipe
    @recipe = if params[:recipe].present?
                Recipe.find_by(id: params[:recipe])
              end

    # If recipe is not found or params[:recipe_id] is empty, initialize a default recipe
    @recipe ||= Recipe.new(
      name: @options_missions["fortune"]["long_name"],
      difficulty: 0,
      speed: 2,
      description: @options_missions["fortune"]["desc"]
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
      @options_missions["fortune"]["results"].sort.reverse.each do |range|
          if range[0].to_i <= total
            @result = range[1]
            break
          end
      end
    else
      @options_missions["results"].sort.reverse.each do |range|
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

    @effect_major = @options_missions["effect_major"]
    @effect_minor = @options_missions["effect_minor"]

    @fortune = fortune
  end

  def list
    open_tag = @options_missions["tags"]["open"]
    long_tag = @options_missions["tags"]["long"]

    factions = Faction.all
    masters_ids = User.where(faction: Faction.find_by(name: 'master')).pluck(:discourse_id)

    date_past = Date.new(2000, 1, 1)
    date_today = Date.today
    date_future = Date.new(3000, 1, 1)

    missions_by_tag = DiscourseApi::DiscourseGetData.get_missions_by_tag(open_tag)

    topic_ids = missions_by_tag.map { |topic| topic["id"] }

    @missions = {}

    missions_by_id = DiscourseApi::DiscourseGetData.get_missions_by_id(topic_ids)
    missions_by_id.each do | id, topic |

      color = "row-striped"
      if topic["topic_timer"].present?
        # Timer is present
        date = Date.parse(topic["topic_timer"]["execute_at"])
        # Timer is of incorrect type
        if topic["topic_timer"]["status_type"] != "bump"
          message = t('.no_bump')
          color = "bg-warning"
        end
      else
        # Timer is not present
        if topic["post_stream"]["posts"].select { |post| post['action_code'] == 'autobumped' }.last
          # Topic has been bumped today
          date = date_today
        elsif masters_ids.include?(topic["post_stream"]["posts"].last["user_id"]) && topic["post_type"] == 1
          # Last message is a normal message by master
          date = date_future
          message = t('.awaiting_player')
        else
          # All other cases
          date = date_past
          message = t('.no_date_long')
        end
      end

      tags = topic["tags"]

      long = nil
      if tags.include?(long_tag)
        long = true
        date = date_past + 1
      end

      # Filter posts where post_type == 1
      normal_posts = topic["post_stream"]["posts"].select { |post| post['post_type'] == 1 }

      # Get the last normal post
      last_normal_post = normal_posts.last

      post = topic["post_stream"]["posts"][0]["cooked"]
      match_data = post.match(/<h[1-6][^>]*>.*?Objetivo.*?<\/h[1-6]>(.*?)<h[1-6][^>]*>/m)
      target = match_data ? match_data[1].strip : t('.no_target')

      category = (factions.find_by(category_id: topic["category_id"])&.long_name || t('activerecord.attributes.faction.no_category'))

      if date == date_today
        today = true
      end

      @missions[id] = {
        title: topic["fancy_title"],
        category: category,
        assigned_to: topic.fetch("assigned_to_user", {})&.fetch("username", t('.no_assigned')),
        date: date,
        target: target,
        message: message,
        color: color,
        today: today,
        long: long,
        last_normal_post: last_normal_post["post_number"]
      }
    end

    @missions
    @speed = @options_missions['speed'].pluck("days").map { |item| item.to_s[/\d+/]&.to_i }.reject { |item| item == 0 || item.nil? }
  end

  def stats
    if Rails.env.development?
      @verify = false
    else
      @verify = true
    end

    # Create a new Faraday connection
    connection= Faraday.new(
      ssl: {verify: @verify}, # Disabling verify for development
      headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'multipart/form-data'},
      url: 'https://www.valar.es'
      )

      missions = [] # To store all the missions

      page = 0

      loop do
        response = connection.get('/search.json', period: 'all', q: 'tags:cerrada,abierta,stand-by ' + @options_missions["stats"]["game_category"] + ' order:latest', page: page)
        json_response = JSON.parse(response.body)

        if json_response.fetch('topics', {}).present?
          missions.concat(json_response['topics'])
        else
          break
        end

        # Move to the next page
        page += 1
      end

      missions= missions.uniq

      @total = missions.length
      @faction_totals = missions.group_by { |item| item["category_id"] }
                            .transform_keys { |category_id| "#{category_id}" }
                            .transform_values(&:count)
  end

  def set_mission_timer
    @topic_id = params[:topic_id].to_i
    days_to_add = params[:days].to_i

    today = Date.today
    target_date = calculate_ellapsed_date(days_to_add)

    if target_date == today
      time = Time.current + 1.minute
    else
      time = target_date.to_time.change({ hour: 8, min: 30 })
    end

    timer = {
       "time": time,
	      "status_type": "bump"
      }

    response = DiscourseApi::DiscoursePostData.set_topic_timer(@topic_id, timer)
    @toast = t('.set_bump_date', date: DateTime.parse(JSON.parse(response.body)["execute_at"]).strftime("%d %b %Y"))
    @mission = { date: target_date}

    respond_to do |format|
      if response.success?
        format.js
      end
    end
  end

private
  def set_options
    options = GameOptionsService.fetch

    if options[:missions].blank?
      redirect_to settings_url, warning: t('activerecord.errors.messages.options_not_ready', tool_name: @tool.title)
    else
      set_options_settings(options)
      set_options_missions(options)
    end
  end

  def simplify_factors(factors)
    counted_factors = factors.group_by { |factor| factor }.transform_values(&:count)

    counted_factors.map do |element, count|
      count > 1 ? "#{count}x #{element}" : element
    end
  end
end
