class DomainsController < ApplicationController
  def index
    @domains = Domain.popular
=begin
    @domains = Link.find(:all, 
      :select => "domain, COUNT(*) AS linkages_count",
      :joins => "JOIN linkages ON links.id = linkages.link_id",
      :conditions => "domain IS NOT NULL",
      :group => "domain", :order => "COUNT(*) DESC"
    )
=end
  end
  
  def show
    @domain = Domain.find_by_name params[:id].gsub('_', '.')
=begin
    @links = Link.paginate(:page => params[:page], 
      :select => "links.id, domain, page_title, url, COUNT(*) AS linkages_count",
      :order => "COUNT(*) DESC, links.id",
      :group => "links.id, domain, page_title, url",
      :joins => "JOIN linkages ON links.id = linkages.link_id",
      :conditions => {:domain => @domain})
=end
  end
end
