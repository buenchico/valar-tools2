class SessionsController < ApplicationController

  def create
    sso = SsoWithDiscourse::Sso.new
    session[:sso] = sso
    redirect_to sso.request_url, allow_other_host: true
    $sso = sso
  end

  if Rails.env.development?
    def create_hammer
      @user = User.find_by(player: 'hammer_ortiz')
      cookies.permanent[:auth_token] = @user.auth_token
      redirect_to root_url
    end

    def create_nemo
      @user = User.find_by(player: 'Nemo')
      cookies.permanent[:auth_token] = @user.auth_token
      redirect_to root_url
    end

    def create_master
      @user = User.find_by(player: 'valar')
      cookies.permanent[:auth_token] = @user.auth_token
      redirect_to root_url
    end
  end

  def destroy
    @id = @current_user.discourse_id.to_s

    @url = 'https://www.valar.es/admin/users/'+ @id +'/log_out.json'

    Faraday.default_adapter = :net_http

    if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

    con = Faraday.new(
      ssl: {verify: @verify}, # Disabling verify for development
      url: @url,
      headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'multipart/form-data'}
    )

    res = con.post @url

    if res.body['success'] == 'success'
      cookies.delete(:user)
      cookies.delete(:auth_token)
      cookies.delete(:avatar_url)

      redirect_to root_url
      flash[:danger] = 'Sesión cerrada correctamente.'
    else
      redirect_to root_url
      flash[:danger] = 'Se ha producido un error, por favor inténtelo de nuevo.'
    end
  end

  def destroy_sso
    cookies.delete(:auth_token)

    redirect_to "https://www.valar.es", allow_other_host: true
  end

  def sso
    sso = $sso
    sso.parse(params)
    @user = User.find_by(discourse_id: $sso.user_info[:external_id])
    if $sso.status == 'success' && @user != nil
      cookies.permanent[:auth_token] = @user.auth_token
      @user.player = $sso.user_info[:username]
      @user.avatar_url = $sso.user_info[:avatar_url]
      @user.save

      redirect_to root_url
      flash[:success] = 'Sesión iniciada correctamente como ' + $sso.user_info[:username]
    elsif $sso.status == 'success' && @user == nil
      @user = User.new(player: $sso.user_info[:username], discourse_id: $sso.user_info[:external_id], faction: Faction.find(3), avatar_url: $sso.user_info[:avatar_url])
      if @user.save
        cookies.permanent[:auth_token] = @user.auth_token
        redirect_to root_url
        flash[:success] = 'Bienvenido a Valar Tools, contacta con los Masters para recibir permisos'
      else
        redirect_to root_url
        flash[:danger] = 'Se ha producido un error, por favor inténtelo de nuevo'
      end
    else
      redirect_to root_url
      flash[:danger] = 'Se ha producido un error, por favor inténtelo de nuevo'
    end
  end
end
