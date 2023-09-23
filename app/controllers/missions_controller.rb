class MissionsController < ApplicationController
  before_action :set_tool
  before_action :check_master

  def index
    @missions = Mission.all
  end

  def get_missions_closed
    @missions = DiscourseApi::DiscourseGetData.get_missions(156, 'cerrada')
    @missions.each do | mission |
      Mission.create(name: mission['title'], discourse_id: mission['id'], status: 'closed', faction: Faction.find_by(category_id: mission['category_id']))
    end
  end

  def get_missions_open
    @missions = DiscourseApi::DiscourseGetData.get_missions(156, 'abierta')
    @missions.each do | mission |
      Mission.create(name: mission['title'], discourse_id: mission['id'], status: 'open', faction: Faction.find_by(category_id: mission['category_id']))
    end
  end

  def calculate
    # respond_to :js
  end
end
