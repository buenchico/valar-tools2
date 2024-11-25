class SearchController < ApplicationController
  before_action :set_options

  def index
    @query = params[:query]
    multisearch(@query)
  end

  def search
    @query = params[:search]
    multisearch(@query)
  end

  def multisearch(query)
    if query.present?
      # Use PgSearch to search across multiple models and fields
      search = PgSearch.multisearch(query)
    else
      search = []
    end

    results = []
    search.each do | item |
      record = item.searchable_type.constantize.find(item.searchable_id)
      keep_record = false
      case item.searchable_type
      when 'Family', 'Location'
        if @current_user.is_admin?
          keep_record = true
        elsif (@current_user.is_master? && record.game == active_game)
          keep_record = true
        elsif (record.visible == true && record.game == active_game)
          keep_record = true
        end
      when 'Clock'
        if @current_user.is_master?
          keep_record = true
        elsif record.visible
          keep_record = true
        end
      when 'Faction'
        if @current_user.is_admin?
          keep_record = true
        elsif (@current_user.is_master? && record.games.include?(active_game))
          keep_record = true
        elsif (record.active == true && record.games.include?(active_game))
          keep_record = true
        end
      when 'Army'
        if @current_user.is_master?
          keep_record = true
        elsif (@current_user && record.factions.include?(@current_user.faction))
          keep_record = true
        end
      else
        keep_record = true
      end

      if keep_record == true
        results << record
      end
    end

    @results = results.uniq
  end
private
  def set_options
    @options_armies = get_options(Tool&.find_by(name: "armies"))
    set_options_armies
    @options_clocks = get_options(Tool&.find_by(name: "clocks"))
    set_options_clocks
  end
end
