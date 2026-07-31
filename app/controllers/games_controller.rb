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
    @factions_special = Faction.where(name: ['master', 'player'])
    @factions_game = @game.factions.where.not(name: ['admin', 'master', 'player']).order(:name)
    @all_factions = @factions_special.to_a + @factions_game.to_a
    @users = User.where.not(player: 'valar').order('LOWER(player)')
  end

  def setup_complete
    game = Game.find(params[:id])

    selected_faction_ids = params[:faction_ids] # Get selected faction IDs from form parameter
    selected_factions = Faction.where(id: selected_faction_ids) # Fetch Faction records for selected factions

    selected_factions.each do |faction|
      faction.active = true
      faction.save

      if !faction.save
        @errors << faction.errors
      end

      users = params[:users] || {}

      puts users

      users.each do | user_id, value |
        player = User.find(user_id.to_i)
        if !player.update(faction_id: value["faction"].to_i)
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
      if  Game.update_all(active: false) &&
          Tool.where.not(role: 'admin').where.not(name: ['factions', 'players']).update_all(active: false) &&
          Faction.where.not(name: ['admin', 'master', 'player']).update_all(active: false) &&
          User.where.not(player: 'valar').update_all(faction_id: Faction.find_by(name: 'player').id)

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
