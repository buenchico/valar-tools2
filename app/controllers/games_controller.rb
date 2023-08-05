class GamesController < ApplicationController
  before_action :set_game, only: [:edit, :update, :destroy, :set_active_game]
  before_action :check_admin

  def new
    @game = Game.new
    @tools = Tool.all.order(:sort).order(:id)
  end

  # GET /game/1/edit
  def edit
    @tools = Tool.all.order(:sort).order(:id)
  end

  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to settings_url, success: 'Partida creada correctamente.' }
      else
        format.html {  redirect_to settings_url, danger: @game.errors  }
      end
    end
  end

  # POST /game/1/edit
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to settings_url, success: 'Partida configurada correctamente.' }
      else
        format.html {  redirect_to settings_url, danger: @game.errors  }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @game.destroy
        format.html { redirect_to settings_url, success: 'Partida eliminada correctamente.' }
      else
        format.html {  redirect_to settings_url, danger: @game.errors  }
      end
    end
  end

  def setup
    @game = Game.find(params[:id])
    @factions = Faction.all.order(:id)
    @users = User.offset(1).all.order(:id)
  end

  def setup_complete
    game = Game.find(params[:id])

    Faction.update_all(active: false) # setting all factions as inactive

    selected_faction_ids = params[:faction_ids].unshift("3", "2", "1") # Get selected faction IDs from form parameter
    selected_factions = Faction.where(id: selected_faction_ids) # Fetch Faction records for selected factions

    selected_factions.each do |faction|
      # Check if the faction does not already have the game associated
      unless faction.games.exists?(game.id)
        faction.games << game # Add @game to each faction's games association
      end
      faction.active = true
      faction.save

      if !faction.save
        @errors << faction.errors
      end

      User.find(1).update(faction_id: 1)
      User.all.offset(1).update_all(faction_id: 3)

      users_array = params[:users] || []

      users_array.each do | user |
        player = User.find(user["id"].to_i)
        if !player.update(faction_id: user["faction"].to_i)
          @errors << player.errors
        end
      end
    end

    if !game.update(game_params)
      @errors << game.errors
    end

    if !game.update(active: true)
      @errors << game.errors
    end

    game_params["game_tools_attributes"].each do | key, gametool|
      tool = GameTool.find(gametool["id"]).tool

      if !tool.update(active: gametool["active"])
        @errors << tool.errors
      end
    end

    respond_to do |format|
      if @errors.blank?
        format.html { redirect_to settings_url, success: 'Partida inicializada correctamente.' }
      else
        format.html { redirect_to settings_url, danger: @game.errors }
      end
    end
  end

  def unset_active_game
    respond_to do |format|
      if Game.update_all(active: false) && Tool.where.not(role: 'admin').update_all(active: false)
        format.html { redirect_to settings_url, success: 'Partida terminada correctamente.' }
      else
        format.html { redirect_to settings_url, danger: @game.errors }
      end
    end
  end

private
  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:name, :prefix, :title, :icon_url, game_tools_attributes: [:id, :active, :options])
          .tap do |whitelisted|
      if whitelisted[:game_tools_attributes].present?
        whitelisted[:game_tools_attributes].each do |index, tool_params|
          if tool_params[:options].present?
            whitelisted[:game_tools_attributes][index][:options] = JSON.parse(tool_params[:options])
          end
        end
      end
    end
  end
end
