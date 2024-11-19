class SearchController < ApplicationController
  def search
    @search = params[:search]
    if @search.present?
      # Use PgSearch to search across multiple models and fields
      @results = PgSearch.multisearch(@search)
    else
      @results = []
    end

    # search_result = @results.first  # Assuming the id is 12, as in your example

    # Get the model type and ID
    #model_type = search_result.searchable_type
    #model_id = search_result.searchable_id

    # Find the corresponding model instance (e.g., a Family)
    #original_item = @results.first.searchable_type.constantize.find(@results.first.searchable_id).name
  end
end
