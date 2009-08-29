class LinksController < ApplicationController
  def index
    @links = Link.paginate(:select => "links.id, page_title, expanded_url, url, COUNT(*) AS linkages_count", :page => params[:page], :order => "COUNT(*) DESC, links.id", :group => "links.id, page_title, expanded_url, url", :joins => "JOIN linkages ON links.id = linkages.link_id")
  end
  
  def show
    @link = Link.find(params[:id])
    
  end
end
