class MissionsController < ApplicationController
  before_action :set_tool
  before_action :check_master
  before_action :set_mission, only: [:edit, :update]
  before_action :set_options, only: [:index, :edit, :update]


  def index
    @missions = Mission.all
  end

  def edit
  end

  def update
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

  def missions_api(missions)
    game_category_id = active_game.category_id
    @errors = []
    @count = 0
    @missions = Mission.all

    missions.each do | mission |
      if !@missions.find_by(discourse_id: mission["id"])
        @mission = Mission.new(
          name: mission['title'],
          discourse_id: mission['id'],
          status: 'open',
          faction: Faction.find_by(category_id: mission['category_id']),
          game: active_game
        )
        if @mission.save
          @count += 1
        else
          @errors << mission['title']
        end
        puts "XXXXXXXXXXXXXXXXXXXXXXXX"
        puts mission['title']
        puts @mission.errors.to_json
        puts "XXXXXXXXXXXXXXXXXXXXXXXXXX"
      else
        @mission = @missions.find_by(discourse_id: mission["id"])
        if @mission.update(
          name: mission['title'],
          discourse_id: mission['id'],
          status: 'open',
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
        message = '<p>' + @count.to_s + ' facciones han sido sincronizadas correctamente.</p>' +
                  '<p>' + @errors.length.to_s + ' facciones han fallado al ser creadas.</p>' +
                  '<p>' + @errors.to_s + '</p>'
        format.html { redirect_to missions_url, danger: message }
      end
    end
  end
end
