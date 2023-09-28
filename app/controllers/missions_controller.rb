class MissionsController < ApplicationController
  before_action :set_tool
  before_action :check_master
  before_action :set_mission, only: [:edit, :update]
  before_action :set_options, only: [:index, :edit, :update, :sync_missions, :initialize_missions]


  def index
    @missions = Mission.where(status: ["open","standby"])
  end

  def edit
    update_status_from_api(@mission)
  end

  def update
    original_title = @mission.name
    respond_to do |format|
      if @mission.update(mission_params)
        flash.now[:success] = t('messages.success.update', thing: @mission.name.strip + " (id: " + @mission.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @mission.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: original_title + " (id: " + @mission.id.to_s + ")", method: 'update' } }
      end
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
      roll = response.body['result']['random']['data'].sort
    else
      roll = Array.new(3) { rand(1..10) }.sort
    end

    difficulty = params[:difficulty].to_i,
    tokens = params[:tokens].to_i,
    advantage = params[:advantage].to_i,
    misc = params[:misc].to_i,
    role = params[:role].to_i

    puts params[:tokens]
    puts "XXXXXXXXXXXXXXXXXX"
    puts difficulty
    #subtotal = difficulty + tokens + advantage + misc + role
    #total = roll[1].to_i + subtotal

    @data = {
      roll: roll,
      difficulty: difficulty,
      tokens: tokens,
      advantage: advantage,
      misc: misc,
      role: role,
      subtotal: "subtotal",
      total: "total"
    }
  end

  def sync_missions
    open_missions = DiscourseApi::DiscourseGetData.get_missions(active_game.category_id, 'abierta')
    update_from_api(open_missions)
  end

  def initialize_missions
    open_missions = DiscourseApi::DiscourseGetData.get_missions(active_game.category_id, 'abierta')
    closed_missions = DiscourseApi::DiscourseGetData.get_missions(active_game.category_id, 'cerrada')
    missions = open_missions + closed_missions
    update_from_api(missions)
  end

private
  def set_mission
    @mission = Mission.find(params[:id])
  end

  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options

    @inverted_status = {}

    @options["status"].each do |key, value|
      @inverted_status[value["name"]] = key
    end

    if @options.blank?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de misiones'
    end
  end

  def mission_params
    params.require(:mission).permit(:name, :discourse_id, :status, :notes, :started, :resolved, :game_id, :user_id, :faction_id)
  end

  def update_status_from_api(mission)
    response = DiscourseApi::DiscourseGetData.get_mission_by_id(mission.discourse_id)
    tag = JSON.parse(response.body)["tags"][0].strip

    tag = @inverted_status.fetch(tag, "error")

    mission.update(status: tag)
  end

  def update_from_api(missions)
    game_category_id = active_game.category_id
    @errors = []
    @count = 0
    @missions = Mission.all

    missions.each do | mission |
      tag = @inverted_status.fetch(mission['tags'][0].strip, "error")

      faction = Faction.find_by(category_id: mission['category_id'])
      if faction.nil?
        user_discourse_id = mission['posters'][0]['user_id']
        faction = User.find_by(discourse_id: user_discourse_id).faction
        if faction.nil?
          faction = Faction.find_by(name: "master")
        end
      end

      user =

      if !@missions.find_by(discourse_id: mission["id"])
        @mission = Mission.new(
          name: mission['title'],
          discourse_id: mission['id'],
          status: tag,
          started: mission['created_at'],
          faction: faction,
          game: active_game,
          user: user
        )
        if @mission.save
          @count += 1
        else
          @errors << mission['title']
        end
      else
        @mission = @missions.find_by(discourse_id: mission["id"])
        if @mission.update(
          name: mission['title'],
          discourse_id: mission['id'],
          status: tag,
          started: mission['created_at'],
          faction: faction,
          game: active_game,
          user: user
        )
          @count += 1
        else
          @errors << mission['title'] + @mission.errors
        end
      end
    end

    respond_to do |format|
      if @errors.length == 0
        format.html { redirect_to missions_url, success: @count.to_s + ' facciones han sido sincronizadas correctamente. Por favor, revisa las partidas.' }
      else
        message = '<p>' + @count.to_s + ' misiones han sido sincronizadas correctamente.</p>' +
                  '<p>' + @errors.length.to_s + ' misiones han fallado al ser creadas.</p>' +
                  '<p>' + @errors.to_s + '</p>'
        format.html { redirect_to missions_url, danger: message }
      end
    end
  end
end
