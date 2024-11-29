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
        if @current_user.is_admin?
          true
        elsif @current_user.is_master? && record.game == active_game
          true
        elsif record.visible && record.game == active_game
          true
        end
      when 'Clock'
        @current_user.is_master? || record.visible
      when 'Faction'
        if @current_user.is_admin?
          true
        elsif @current_user.is_master? && record.games.include?(active_game)
          true
        elsif record.active && record.games.include?(active_game)
          true
        end
      when 'Army'
        if @current_user.is_master?
          true
        elsif @current_user && record.factions.include?(@current_user.faction)
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
    set_options_armies
    @options_clocks = get_options(Tool&.find_by(name: "clocks"))
    set_options_clocks
    @options_families = get_options(Tool&.find_by(name: "families"))
  end
end
