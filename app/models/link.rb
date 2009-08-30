class Link < ActiveRecord::Base
  has_many :linkages
  #has_many :short_links
  has_many :users, :through => :linkages
  belongs_to :domain

  before_save :update_linkage_domains
  after_create :enqueue
  include Rehab::Enqueueable

  def ensure_domain
    return unless self.domain_name
    self.domain ||= Domain.find_or_create_by_name domain_name
  end

  def update_linkage_domains
    if domain_id_changed?
      linkages.each { |lkg| lkg.domain = domain; lkg.save unless lkg.new_record? }
    end
  end
  
  def self.fetch_expanded_urls
    find_in_batches(:conditions => ["followed = ?", false]) do |links|
      links.each do |link|
        link.expand_url
        link.save
      end
    end
  end
  
  def self.set_domain_fields
    find_in_batches(:conditions => "domain_id IS NULL OR domain_name IS NULL OR url NOT LIKE ('%' || domain_name || '%')") do |links|
      links.each do |link|
        link.set_domain
        link.save
      end
    end
  end

  def set_domain
    begin
      unless self.domain_name
        uri = URI.parse(self.url)
        self.domain_name = uri.host.try(:gsub, /www\d*\./, '')
      end
      ensure_domain
    rescue URI::InvalidURIError => e
    end
  end
  
  def expand_url
    if expanded_url = self.class.expand_url(url)
      #self.short_links.create :url => self.url
      self.original_url = url
      self.url = expanded_url
      set_domain
      true
    else
      false
    end
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
  
  def self.extract_urls(text)
    URI.extract(text, 'http') if text.include?('http://')
  end
  
  def fetch_title
    Timeout::timeout(5) do
      raw_page_title = Nokogiri.HTML(open(url).read).at("//title").text.strip rescue nil
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      self.page_title = ic.iconv(raw_page_title + ' ')[0..-2]
    end
  rescue Timeout::Error => e
    nil
  end
  
  def perform
    expand_url
    fetch_title
    save
  rescue => e
  end
end
