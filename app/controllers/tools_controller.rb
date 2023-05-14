class ToolsController < ApplicationController
  before_action :set_tool, only: [:edit, :update, :destroy]
  before_action :check_admin

  def new
    @tool = Tool.new
  end

  # GET /tool/1/edit
  def edit
  end

  def create
    @tool = Tool.new(tool_params)

    respond_to do |format|
      if @tool.save
        format.html { redirect_to settings_url, success: 'Herramienta creada correctamente.' }
      else
        format.html {  redirect_to settings_url, danger: @tool.errors  }
      end
    end
  end

  # POST /game/1/edit
  def update
    respond_to do |format|
      if @tool.update(tool_params)
        format.html { redirect_to settings_url, success: 'Herramienta configurada correctamente.' }
      else
        format.html { redirect_to settings_url, danger: @tool.errors  }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @tool.destroy
        format.html { redirect_to settings_url, success: 'Herramienta eliminada correctamente.' }
      else
        format.html {  redirect_to settings_url, danger: @tool.errors  }
      end
    end
  end

private
  def set_tool
    @tool = Tool.find(params[:id])
  end

  def tool_params
    params.require(:tool).permit(:name, :title, :short_title, :icon_url, :options, :options_info, :role, :sort, :active, game_tools_attributes: [:id, :active, :options])
      .tap do |whitelisted|
        whitelisted[:game_tools_attributes].each do |index, tool_params|
          if tool_params[:options].present?
            whitelisted[:game_tools_attributes][index][:options] = JSON.parse(tool_params[:options])
          end
        end
      end
  end
end
