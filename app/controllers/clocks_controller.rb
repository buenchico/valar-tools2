class ClocksController < ApplicationController
  before_action :set_tool
  before_action :set_options
  before_action :set_clock, only: [:show, :update, :edit, :destroy]
  before_action :check_master, except: [:index, :show]

  def index
    if @current_user&.is_master?
      clocks = Clock.all
    else
      clocks = Clock.where(visible: true)
    end
    @clocks_open = clocks.open
    @clocks_close = clocks.closed
  end

  def new
    @clock = Clock.new
  end

  def show
  end

  def edit
  end

  def edit_multiple
    @clocks = Clock.where(id: params[:clock_ids]).order(:name)
    @action = params[:button]
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
    original_name = @clock.name
    respond_to do |format|
      if @clock.update(clock_params)
        flash.now[:success] = t('messages.success.update', thing: @clock.name.strip + " (id: " + @clock.id.to_s + ")", count: 1)
        format.js
      else
        flash.now[:danger] = @clock.errors.to_hash
        format.js { render 'layouts/error', locals: { thing: original_name + " (id: " + @clock.id.to_s + ")", method: 'update' } }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @clock.destroy
        flash.now[:danger] = t('messages.success.destroy', thing: @clock.name.strip + " (id: " + @clock.id.to_s + ")", count: 1)
        format.js
      else
        format.html {  redirect_to locations_url, danger: @clock.errors  }
      end
    end
  end

  def destroy_multiple
    @clocks = Clock.where(id: params[:clock_ids])
    count = @clocks.count

    respond_to do |format|
      if params[:clock][:confirm] == 'DELETE'
        if @clocks.destroy_all
          format.html { redirect_to clocks_url, success: t('messages.multiple.success', model:  Clock.model_name.human(:count => 2).downcase, succeed: count) }
        else
          format.html { redirect_to clocks_url, danger: t('messages.multiple.success', model:  Clock.model_name.human(:count => 2).downcase, failed: count, succeed: 0) }
        end
      else
        format.html { redirect_to clocks_url, danger: t('messages.multiple.validation') }
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
      redirect_to settings_url, warning: t('activerecord.errors.messages.options_not_ready', tool_name: @tool.title)
    else
      @sizes = @options["sizes"]
      @outcomes = @options["outcomes"]
      @styles = @options["styles"]
    end
  end

  def clock_params
    params.require(:clock).permit(:name, :size, :status, :description, :family_id, :outcome, :visible, :style, :left, :right)
  end
end
