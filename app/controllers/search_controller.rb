class SearchController < ApplicationController
  def search
    search = params[:search]
    if search.present?
      # Use PgSearch to search across multiple models and fields
      @results = PgSearch.multisearch(search)
    else
      @results = []
    end

    search_result = @results.first  # Assuming the id is 12, as in your example

    # Get the model type and ID
    model_type = search_result.searchable_type
    model_id = search_result.searchable_id

    # Find the corresponding model instance (e.g., a Family)
    original_item = model_type.constantize.find(model_id)

    puts "/////"
    puts search
    puts @results
    puts @results.length
    puts @results.first
    puts original_item.name
    puts "/////"
  end
end
