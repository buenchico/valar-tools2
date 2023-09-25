# app/controllers/issues_controller.rb
class IssuesController < ApplicationController
  require 'faraday'
  require 'json'

  before_action :check_player

  def new
  end

  def create
    connection = Faraday.new(url: 'https://api.github.com/repos/buenchico/valar-tools2/issues') do |conn|
      conn.headers['Authorization'] = "token #{ENV['GITHUB_ISSUES_API']}"
      conn.headers['Content-Type'] = 'application/json'
      conn.adapter Faraday.default_adapter
    end

    title = params[:title]
    body = params[:description] + "\n Por " + @current_user.player + "."

    issue_data = { title: title, body:  }
    response = connection.post do |req|
      req.body = issue_data.to_json
    end

    # Handle the GitHub API response as needed
    if response.success?
      flash[:success] = 'Error registrado correctamente.'
    else
      flash[:danger] = 'El error no ha sido registrado.'
      # Optionally, you can log the response for debugging purposes.
    end

    redirect_to root_url
  end
end
