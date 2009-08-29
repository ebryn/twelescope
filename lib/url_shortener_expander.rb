class UrlShortenerExpander
  def self.get(short_url)
    Nokogiri.HTML(open(short_url).read).at("//iframe[@id='source']")['src']
  end
end