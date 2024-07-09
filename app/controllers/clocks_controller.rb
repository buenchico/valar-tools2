class ClocksController < ApplicationController
  before_action :set_tool
  before_action :set_options
  before_action :set_clock, only: [:show, :update]
  before_action :check_master, except: [:index, :show]

  def index
    if @current_user&.is_master?
      clocks = Clock.all
    else
      clocks = Clock.where(visible: true)
    end
    @clocks_open = clocks.where.not("size = status")
    @clocks_closed = clocks.where("size = status")
  end

  def new
    @clock = Clock.new
  end

  def show
  end

  def create
    @clock = Clock.new(clock_params)

    respond_to do |format|
      if @clock.save
        format.html { redirect_to clocks_url, success: 'Reloj creado correctamente.' }
      else
        format.html { redirect_to clocks_url, danger: @clock.errors }
      end
    end
  end

  def update
    respond_to do |format|
      if @clock.update(clock_params)
        flash.now[:success] = t('messages.success.update', thing: @clock.name.strip + " (id: " + @clock.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @clock.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: original_title + " (id: " + @clock.id.to_s + ")", method: 'update' } }
      end
    end
  end

private
  def set_clock
    @clock = Clock.find(params[:id])
  end

  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    if @options.blank?
      redirect_to settings_url, warning: t('activerecord.errors.messages.game_not_ready', tool_name: @tool.title)
    else
      @sizes = @options["size"]
      @outcomes = @options["outcome"]
    end
  end

  def clock_params
    params.require(:clock).permit(:name, :size, :status, :description, :family_id, :outcome, :visible)
  end
end
