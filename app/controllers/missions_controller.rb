class MissionsController < ApplicationController
  before_action :set_tool
  before_action :check_master
  before_action :set_mission, only: [:edit, :update]
  before_action :set_options, only: [:index, :edit, :update]


  def index
    @missions = Mission.all

    connection = Faraday.new(
      ssl: {verify: false}, # Disabling verify for development
      headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'multipart/form-data'},
      url: 'https://www.valar.es'
      )

    response = connection.get('/t/2983.json')
    json_response = JSON.parse(response.body)
    if json_response["tags"].include?("bugs")
      json_response["tags"] == json_response["tags"] = json_response["tags"].map { |item| item == "bugs" ? "cerrada" : item }
    end

    body = {tags[]": ["cerrada"]}

    update_mission = connection.put("/t/valar-tools-bugs/2983.json", body.to_json)
    puts json_response["tags"]
    puts update_mission.body
  end

  def edit
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
    # respond_to :js
  end

  def sync_missions
    open_missions = DiscourseApi::DiscourseGetData.get_missions(active_game.category_id, 'abierta')
    missions_api(open_missions)
  end

  def initialize_missions
    open_missions = DiscourseApi::DiscourseGetData.get_missions(active_game.category_id, 'abierta')
    closed_missions = DiscourseApi::DiscourseGetData.get_missions(active_game.category_id, 'cerrada')
    missions = open_missions + closed_missions
    missions_api(missions)
  end

private
  def set_mission
    @mission = Mission.find(params[:id])
  end

  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    if @options.blank?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la lista de misiones'
    end
  end

  def mission_params
    params.require(:mission).permit(:name, :discourse_id, :status, :notes, :started, :resolved, :game_id, :user_id, :faction_id)
  end

  def missions_api(missions)
    game_category_id = active_game.category_id
    @errors = []
    @count = 0
    @missions = Mission.all

    missions.each do | mission |
      if mission['tags'][0] == 'abierta'
        tag = "open"
      elsif mission['tags'][0] == 'cerrada'
        tag = "cerrada"
      elsif mission['tags'][0] == 'stand-by'
        tag = 'stand-by'
      end

      if !@missions.find_by(discourse_id: mission["id"])
        @mission = Mission.new(
          name: mission['title'],
          discourse_id: mission['id'],
          status: tag,
          started: mission['created_at'],
          faction: Faction.find_by(category_id: mission['category_id']),
          game: active_game
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
          faction: Faction.find_by(category_id: mission['category_id']),
          game: active_game
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
