class UsersController < ApplicationController
  before_action :check_master, except: [:index]
  before_action :set_tool
  before_action :set_user, only: [:edit, :update]

  def index
    inactive_faction_id = Faction.find_by(name: 'player')&.id
    @users = User.joins(:faction)
                 .order(Arel.sql("CASE WHEN #{User.table_name}.faction_id = #{inactive_faction_id} THEN 1 ELSE 0 END, #{Faction.table_name}.name"))
                 .all
    puts User.table_name
  end

  def edit
    @factions = Faction.where(active: true).order(:id)
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_url, success: 'Jugador editada correctamente.' }
      else
        format.html {  redirect_to users_url, danger: @user.errors  }
      end
    end
  end

  def sync_users
    @users_data = DiscourseApi::DiscourseGetData.get_users_data
    @inactive_faction = Faction.find(3)
    @users = User.all.order(:id)
    @count = 0
    @errors = []

    @users_data.each do |x|
      user = x["user"]
      if !@users.find_by(discourse_id: x["id"])
        @user = User.new(
          player: user["username"],
          discourse_id: user["id"],
          faction: @inactive_faction,
          avatar_url: "http://www.valar.es/" + user["avatar_template"].gsub('{size}', '144')
        )

        if @user.save
          @count += 1
        else
          @errors << user["username"] + @user.errors
        end
      else
        @user = @users.find_by(discourse_id: x["id"])
        if @user.update(
          player: user["username"],
          discourse_id: user["id"],
          avatar_url: "http://www.valar.es/" + user["avatar_template"].gsub('{size}', '144')
        )
          @count += 1
        else
          @errors << group["name"]
        end
      end
    end

    respond_to do |format|
      if @errors.length == 0
        format.html { redirect_to users_url, success: @count.to_s + ' jugadores han sido sincronizados correctamente. Por favor, revisa las facciones.' }
      elsif @count == 0
        format.html { redirect_to factions_url, success: 'Todos los jugadores están actualizados. Por favor, revisa las facciones.' }
      else
        message = '<p>' + @count.to_s + ' jugadores han sido sincronizados correctamente.</p>' +
                  '<p>' + @errors.length.to_s + ' jugadores han fallado al ser creados.</p>' +
                  '<p>' + @errors.to_s + '</p>'
        format.html { redirect_to users_url, danger: message }
      end
    end
  end

private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:player, :discourse_id, :avatar_url, :faction_id)
  end
end
