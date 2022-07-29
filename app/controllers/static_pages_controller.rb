class StaticPagesController < ApplicationController
  def home
    @player_tools = Tool.where(active: true).where(role:'player')
    @master_tools = Tool.where(active: true).where(role:'master')
    @admin_tools = Tool.where(active: true).where(role:'admin')
    @inactive_tools = Tool.where(active: false)
  end

  def about
  end

  def contact
  end
end
