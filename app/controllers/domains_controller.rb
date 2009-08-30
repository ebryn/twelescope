class DomainsController < ApplicationController
  def index
    @domains = Link.find(:all, 
      :select => "domain, COUNT(*) AS linkages_count",
      :joins => "JOIN linkages ON links.id = linkages.link_id",
      :conditions => "domain IS NOT NULL",
      :group => "domain", :order => "COUNT(*) DESC"
    )
  end
  
  def show
    @domain = params[:id].gsub('_', '.')
    @links = Link.paginate(:page => params[:page], 
      :select => "links.id, domain, page_title, expanded_url, url, COUNT(*) AS linkages_count",
      :order => "COUNT(*) DESC, links.id",
      :group => "links.id, domain, page_title, expanded_url, url",
      :joins => "JOIN linkages ON links.id = linkages.link_id",
      :conditions => {:domain => @domain})
  end
end
