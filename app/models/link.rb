class Link < ActiveRecord::Base
  has_many :linkages
  has_many :users, :through => :linkages
  after_create :enqueue
  
  def enqueue
    Delayed::Job.enqueue self
  end
  
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
    begin
      uri = URI.parse url
      Net::HTTP.start( uri.host, uri.port ) do |http|
        http.read_timeout = 5
        response = http.head(uri.request_uri)
        if ["301", "302"].include?( response.code ) && response['Location']
          location = response['location'] 
          location = "http://#{uri.host}/#{location}" if location =~ /^\//
          expand_url location
        else
          if uri.host == "om.ly"
            UrlShortenerExpander.get(url)
          else
            url
          end
        end
      end
    rescue Timeout::Error => e
      logger.debug "FUCK! #{url}"
      nil
    rescue Net::HTTPBadResponse => e
      logger.debug "WTF? #{url}"
      nil
    rescue URI::InvalidURIError => e
      nil
    rescue SocketError => e
      nil
    end
  end
  
  def fetch_title
    Timeout::timeout(5) do
      self.page_title = Nokogiri.HTML(open(expanded_url || url).read).at("//title").text.strip rescue nil
    end
  rescue Timeout::Error => e
    nil
  end
  
  def perform
    expand_url
    set_domain
    fetch_title
    save
  end
end
