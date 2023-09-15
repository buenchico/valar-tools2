class FactionsController < ApplicationController
  before_action :check_master, except: [:index, :show, :edit_fleets_notes, :update_fleets_notes]
  before_action :set_tool
  before_action :set_options
  before_action :set_faction, only: [:edit, :edit_fleets, :edit_fleets_notes, :update_fleets_notes, :update, :show, :reputation]
  before_action :set_factions_list, only: [:index]
  before_action :check_visble, only: [:show]
  before_action :check_fleets_owner, only: [:edit_fleets_notes, :update_fleets_notes]


  def index
  end

  def edit
    @games = Game.all.order(:id)
  end

  def edit_fleets
  end

  def edit_fleets_notes
  end

  def update_fleets_notes
    respond_to do |format|
      if @faction.update(fleets_notes: params["faction"]["fleets_notes"])
        format.html { redirect_to armies_url, success: 'Flotas editadas correctamente.' }
      else
        format.html { redirect_to armies_url, danger: @faction.errors  }
      end
    end
  end

  def show
    respond_to do | format |
      format.js
      format.html do
        set_factions_list
      end
    end
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
            name: group["name"],
            long_name: group["full_name"],
            title: group["title"],
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
            name: group["name"],
            long_name: group["full_name"],
            title: group["title"],
            discourse_id: group["id"],
            game_ids: Game.find_by(prefix: group["name"].split("-")[0]).id,
            flair_url: group["flair_url"].nil? ? '' : "http://valar.es" + group["flair_url"]
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

  def reputation
    @rep = @faction.reputation.to_i + params[:button].to_i

    respond_to do |format|
      if @faction.update(reputation: @rep)
        format.js
      else
        format.html { redirect_to factions_url, danger: @faction.errors  }
      end
    end
  end

private
  def set_faction
    @faction = Faction.find(params[:id])
  end

  def set_factions_list
    if @current_user&.is_master?
      @factions = Faction.all.order(:id)
    else
      @factions = Faction.where(active: true).where.not(name: ["admin", "player", "master"]).order(:name)
    end
  end

  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
  end

  def check_fleets_owner
    if !@current_user&.is_master?
      if !(@current_user.faction == @faction)
        puts "test///////"
        flash[:danger] = 'No tienes permisos para editar estas flotas.'
        render js: "window.location='/armies'"
      end
    end
  end

  def check_visble
    if !@current_user&.is_master?
      if !(@faction.games.exists?(id: active_game.id) && @faction.active == true)
        respond_to do |format|
          flash[:danger] = 'No tienes permisos para acceder a esta facción.'
          format.js { render js: "window.location='/factions'" }
          format.html { redirect_to factions_url }
        end
      end
    end
  end

  def faction_params
    puts "/////////////////////"
    puts params[:faction][:fleets]
    params.require(:faction).permit(:reputation, :description, :active, :pov, :tokens, :fleets, :fleets_notes, game_ids: []).tap do |whitelisted|
      whitelisted[:fleets] = JSON.parse(params[:faction][:fleets])
    end
  end
end
