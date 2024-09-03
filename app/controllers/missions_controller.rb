class MissionsController < ApplicationController
  before_action :set_tool
  before_action :check_master
  before_action :set_options, only: [:index, :calculate]

  def index
    @recipes = Recipe.all.order(:section)
  end

  def get_recipe
    id = params[:recipe]
    @recipe = Recipe.find(id)
    respond_to :js
  end

  def calculate
    payload = {
      jsonrpc: '2.0',
      method: 'generateIntegers',
      params: {
        apiKey: ENV['RANDOM_ORG_API_KEY'],
        n: 3,
        min: 1,
        max: 10,
        replacement: true
      },
      id: generate_pseudorandom_id
    }

    conn = Faraday.new(url: 'https://api.random.org/json-rpc/4/invoke') do |faraday|
      faraday.request :json
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end

    response = conn.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(payload)
    end

    if response.success?
      roll = response.body['result']['random']['data'].sort
    else
      roll = Array.new(3) { rand(1..10) }.sort
    end

    difficulty = params[:difficulty].to_i
    tokens = params[:tokens].to_i
    advantage = params[:advantage].to_i
    misc = params[:misc].to_i
    role = params[:role].to_i
    factors = params[:factors].to_i

    if roll[1] == 10
      critic = 5
    elsif roll[1] == 1
      critic = -6
    else
      critic = 0
    end

    if advantage == 0
      subtotal = difficulty + tokens + advantage + misc + role + factors
    else
      subtotal = advantage
    end

    total = roll[1].to_i + critic + subtotal

    @options["results"].sort.reverse.each do |range|
        if range[0].to_i <= total
          @result = range[1]
          puts range[1]
          break
        end
    end

    @data = {
      roll: roll,
      critic: critic,
      difficulty: difficulty,
      tokens: tokens,
      advantage: advantage,
      misc: misc,
      role: role,
      subtotal: subtotal,
      total: total
    }
  end

private
  def set_options
    @options = @tool.game_tools.find_by(game_id: active_game&.id)&.options
    @sections = @options["sections"]

    if @options.blank?
      redirect_to settings_url, warning: 'Prepara una partida antes de usar la calculadora de misiones'
    end
  end
end
