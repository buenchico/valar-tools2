class MissionsController < ApplicationController
  before_action :set_tool
  before_action :check_master

  def index
  end

  def calculate
    puts "//////////////////////////"

    respond_to :js
  end
end
