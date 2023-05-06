class ArmiesController < ApplicationController
  before_action :set_tool
  before_action :set_army, only: [:edit, :update, :destroy]


  def index
    @armies = Army.all.order(:group)
  end

  def new
    @army = Army.new
  end

  def create
    @army = Army.new(army_params)

    respond_to do |format|
      if @army.save
        format.html { redirect_to settings_url, success: 'Ejército creado correctamente.' }
      else
        format.html {  redirect_to settings_url, danger: @army.errors }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @army.update(army_params)
        format.html { redirect_to armies_url, success: 'Ejército editado correctamente.' }
      else
        format.html { redirect_to armies_url, danger: @army.errors  }
      end
    end
  end

private
  def set_army
    @army = Army.find(params[:id])
  end

  def army_params
      params.require(:army).permit(:name, :status, :group, :notes, :region, :position, :lord, :visible, :tags, :col0, :col1, :col2, :col3, :col4, :col5, :col6, :col7, :col8, :col9)
  end
end
