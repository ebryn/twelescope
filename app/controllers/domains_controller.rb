class DomainsController < ApplicationController
  def index
    @domains = Link.find(:all, 
      :select => "domain, COUNT(*) AS linkages_count",
      :joins => "JOIN linkages ON links.id = linkages.link_id",
      :conditions => "domain IS NOT NULL",
      :group => "domain", :order => "COUNT(*) DESC"
    )
  end
end
