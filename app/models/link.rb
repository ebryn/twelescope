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
      unless domain && domain.name == domain_name && url.include?(domain_name)
        reset_domain
      end
      ensure_domain
    rescue URI::InvalidURIError => e
    end
  end
  
  def expand_url
    expanded_url = self.class.expand_url(url)
    self.followed = true
    if expanded_url != url 
      self.original_url = url
      self.url = expanded_url
    end
    reset_domain
  end

  def reset_domain
    uri = URI.parse(self.url)
    self.domain_name = uri.host.try(:gsub, /www\d*\./, '')
    unless domain && domain.name == domain_name
      self.domain = Domain.find_or_create_by_name domain_name
    end
  end
    
  def self.expand_url(url)
    begin
      return UrlShortenerExpander.get(url) if url =~ /^http:\/\/om\.ly/ 
      if result = Rehab::UrlLookup.follow( :base_uri => url, :timeout => 2000 )
        return expand_url( result ) if result.is_a? String
        url.to_s
      else
        self.inactive = true
      end
    rescue Timeout::Error => e
      logger.debug "FUCK! #{url}"
      nil
    rescue URI::InvalidURIError => e
      nil
    rescue SocketError => e
      nil
    rescue => e
      logger.debug "Unknown error in url expander for #{url}"
    end
  end

  attr_accessor :queue_priority

  
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
    save!
  rescue => e
  end
end
