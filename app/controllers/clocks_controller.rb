class ClocksController < ApplicationController
  before_action :set_tool

  def index
    @clocks = Clock.all
  end

  def new
    @clock = Clock.new
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

private
  def clock_params
    params.require(:clock).permit(:name, :size, :status, :description, :family)
  end
end
