class FactionsController < ApplicationController
  before_action :check_master, except: [:index]
  before_action :set_tool
  before_action :set_faction, only: [:edit, :update]

  def index
    if @current_user.is_master?
      @factions = Faction.all.order(:id)
    else
      @factions = Faction.where(active: true).order(:name)
    end
  end

  def edit
    @games = Game.all.order(:id)
  end

  def sync_groups
    @groups_data = DiscourseApi::DiscourseGetData.get_groups_data
    @games_prefix = Game.pluck(:prefix)
    @factions = Faction.all.order(:id)
    @count = 0
    @errors = []

    @groups_data.each do |group|
      if @games_prefix.include?(group["name"].split("-")[0])
        if !@factions.find_by(discourse_id: group["id"])
          @faction = Faction.new(
            name: group["name"].split("-")[1],
            long_name: group["title"],
            discourse_id: group["id"],
            game_ids: Game.find_by(prefix: group["name"].split("-")[0]).id,
            flair_url: group["flair_url"].nil? ? '' : "http://valar.es" + group["flair_url"],
            active: false
          )

          if @faction.save
            @count += 1
          else
            @errors << group["name"]
          end
        else
          @faction = @factions.find_by(discourse_id: group["id"])
          if @faction.update(
            name: group["name"].split("-")[1],
            long_name: group["title"],
            discourse_id: group["id"],
            game_ids: Game.find_by(prefix: group["name"].split("-")[0]).id,
            flair_url: group["flair_url"].nil? ? '' : "http://valar.es" + group["flair_url"],
            active: false
          )
            @count += 1
          else
            @errors << group["name"] + @faction.errors
          end
        end
      end
    end

    respond_to do |format|
      if @errors.length == 0
        format.html { redirect_to factions_url, success: @count.to_s + ' facciones han sido sincronizadas correctamente. Por favor, revisa las partidas.' }
      elsif @count == 0
        format.html { redirect_to factions_url, success: 'Todas las facciones están actualizadas. Por favor, revisa las partidas.' }
      else
        message = '<p>' + @count.to_s + ' facciones han sido sincronizadas correctamente.</p>' +
                  '<p>' + @errors.length.to_s + ' facciones han fallado al ser creadas.</p>' +
                  '<p>' + @errors.to_s + '</p>'
        format.html { redirect_to factions_url, danger: message }
      end
    end
  end

  def update
    respond_to do |format|
      if @faction.update(faction_params)
        format.html { redirect_to factions_url, success: 'Facción editada correctamente.' }
      else
        format.html {  redirect_to factions_url, danger: @faction.errors  }
      end
    end
  end

private
  def set_faction
    @faction = Faction.find(params[:id])
  end

  def faction_params
    params.require(:faction).permit(:reputation, :active, game_ids: [])
  end
end
