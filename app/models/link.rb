class Link < ActiveRecord::Base
  before_save :set_domain
  before_save :expand_url
  has_many :linkages
  has_many :users, :through => :linkages
  
  def self.fetch_expanded_urls
    find_in_batches(:conditions => {:expanded_url => nil}) do |links|
      links.each do |link|
        link.expand_url
      end
    end
  end
  
  def self.set_domain_fields
    find_in_batches(:conditions => {:domain => nil}) do |links|
      links.each do |link|
        link.set_domain
      end
    end
  end
  
  def set_domain
    begin
      uri = URI.parse(self.expanded_url || self.url)
      self.domain = uri.host.try(:gsub, /www\d*\./, '')
    rescue URI::InvalidURIError => e
    end
  end
  
  def expand_url
    self.expanded_url = self.class.expand_url url
  end
    
  def self.expand_url(url)
    uri = URI.parse url
    begin
      Net::HTTP.start( uri.host, uri.port ) do |http|
        http.read_timeout = 5
        response = http.head(uri.request_uri)
        if ["301", "302"].include?( response.code ) && response['Location']
          location = response['location'] 
          location = "http://#{uri.host}/#{location}" if location =~ /^\//
          expand_url location
        else
           url
        end
      end
    rescue Timeout::Error => e
      logger.debug "FUCK! #{url}"
      nil
    end
  end
end
