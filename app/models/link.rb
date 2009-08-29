require 'curb'

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
    c = Curl::Easy.new
    c.url = self.url
    c.header_in_body = true
    c.timeout = 2
    # puts link.url
    begin
      c.perform
      c.follow_location = false
      # puts "Response: #{c.response_code}"
      if [301, 302].include? c.response_code
        location = c.body_str.match(/^Location: (.*)$/i)[1].try(:strip)
        self.expanded_url = location if location
      else
        # link.update_attribute :expanded_url, link.url
      end
    rescue Curl::Err::HostResolutionError, Curl::Err::RecvError => e
      puts "Bad url: #{self.url}"
    rescue Curl::Err::TimeoutError => e
    end
  end
end
