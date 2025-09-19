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
    return [] unless query.present?

    # Use pagination on PgSearch results
    search = PgSearch.multisearch(query)

    # Group results by searchable_type
    grouped_results = search.group_by(&:searchable_type)

    results = []

    grouped_results.each do |type, items|
      ids = items.map(&:searchable_id)

      # Fetch all records of this type in one query
      records = type.constantize.where(id: ids).to_a

      # Filter records based on conditions
      filtered_records = filter_records_by_type(type, records)
      results.concat(filtered_records)
    end

    # Paginate the array of results
    @results = Kaminari.paginate_array(results.uniq).page(params[:page]).per(10)
    @count = @results.total_count
  end

  def filter_records_by_type(type, records)
    records.select do |record|
      case type
      when 'Family', 'Location'
        if @current_user&.is_admin?
          true
        elsif @current_user&.is_master? && record.game == active_game
          true
        elsif record.visible && record.game == active_game
          true
        end
      when 'Clock'
        @current_user&.is_master? || record.visible
      when 'Faction'
        if @current_user&.is_admin?
          true
        elsif @current_user&.is_master? && record.games.include?(active_game)
          true
        elsif record.active && record.games.include?(active_game)
          true
        end
      when 'Army'
        if @current_user&.is_master?
          true
        elsif @current_user && record.factions.include?(@current_user.faction) && record.visible
          true
        end
      when 'Unit'
        if @current_user&.is_master?
          true
        elsif @current_user && record.factions.include?(@current_user.faction) && record.visible
          true
        end
      else
        true
      end
    end
  end

private
  def set_options
    @options_armies = get_options(Tool&.find_by(name: "armies"))
    if @options_armies.present?
      set_options_armies
    end
    @options_clocks = get_options(Tool&.find_by(name: "clocks"))
    if @options_clocks.present?
      set_options_clocks
    end
    @options_families = get_options(Tool&.find_by(name: "families"))
    if @options_families.present?
      set_options_families
    end
    @options_locations = get_options(Tool&.find_by(name: "locations"))
    if @options_locations.present?
      set_options_locations
    end
    @options_missions = get_options(Tool&.find_by(name: "missions"))
    if @options_missions.present?
      set_options_missions
    end
  end
end
