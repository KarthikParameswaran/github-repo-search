# ----------------------------------------------------------------
# SearchesController
# SearchesController used to handle search related features and methods
# ----------------------------------------------------------------
class SearchesController < ApplicationController
  # GET  /
  # method to list the search result
  def index
    begin
      @query = index_params[:query]
      result = RepoSearchService.search(index_params[:query])
      @total_size = result.size
      @repos = Kaminari.paginate_array(result).page(index_params[:page]).per(10)
    rescue => e
      @error = true
      puts "Unable to Process Error: #{e}"
    end
  end

  def index_params
    params.permit(:query, :page)
  end
end
