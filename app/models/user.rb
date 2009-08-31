class User < ActiveRecord::Base
  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :linkages
  has_many :taggings
  has_many :links, :through => :linkages
  has_friendly_id :twitter_name
  has_many :domains, :through => :linkages, :uniq => true
  #has_many :friend_linkages, :through => :friends, :class_name => 'Linkage', :source => :linkages, :uniq => true 

  named_scope :popular, :order => "twitter_followers_count DESC", :limit => 25

  include Rehab::Enqueueable
  include Rehab::Tweetable

  def update_from_twitter
    return if no_twitter_account?
    parsed_tweets = parse_tweets
    add_linkages *(parsed_tweets[:urls].flatten.compact)
    add_taggings parsed_tweets[:tags].flatten.compact
    if site_visitor?
      create_users_from_twitter_friends
      read_friends_twitter_feeds
    end
  rescue Rehab::TwitterClient::NoSuchUser
    update_attribute :no_twitter_account, true
  end

  def queue_priority
    return 10 if site_visitor?
    super
  end

  def add_twitter_friend(twitter_name)
    existing_friend = friends.find_by_twitter_name( twitter_name ) 
    unless existing_friend
      new_friend = User.find_or_create_by_twitter_name(twitter_name)
      friendships.create( :friend => new_friend )
    end
    existing_friend || new_friend
  end
  
  def create_users_from_twitter_friends
    friends = twitter.friends(:user => twitter_name )
    return unless friends
    friends.each do |friend|
      friend_record = add_twitter_friend friend['screen_name']
      friend_record.update_attributes(:twitter_friends_count => friend['friends_count'], :twitter_followers_count => friend['followers_count'])
    end
  end

  def eligible_for_tweet_searching?
    self.last_searched.nil? || self.last_searched < 10.minutes.ago
  end

  def parse_tweets
    return [] unless eligible_for_tweet_searching?
    results = search_twitter.query( :params => { :rpp => 100, :from => twitter_name } )[:results]
    self.update_attribute :last_searched, Time.now
    results.inject({:urls => [], :tags => []}) do |data, tweet| 
      data[:urls] << Link.extract_urls(tweet['text'])
      data[:tags] << Tagging.extract_tags(tweet['text'])
      data
    end
  end
  
  def read_friends_twitter_feeds
    return unless self.site_visitor?
    self.friends.each { |f| f.enqueue }
  end
  
  def add_linkages *urls
    urls.each do |url|
      existing_linkage = Linkage.find_by_shared_url url, :include => :link
      link = existing_linkage ? existing_linkage.link : Link.find_or_create_by_url(url)
      link.queue_priority = 15 if site_visitor?
      
      unless self.links.include?(link)
        new_linkage = self.linkages.build :shared_url => url, :link => link
        new_linkage.save unless new_record?
      end
    end
  end

  def add_taggings tags
    tags.each do |tag|
      tagging = self.taggings.find_or_create_by_tag(tag.downcase)
      tagging.increment! :qty
    end
  end
  
  def perform
    update_from_twitter
    finished_loading
  end

  def start_loading
    self.update_attributes :loading => true, :site_visitor => true
    enqueue
  end

  def finished_loading 
    self.update_attribute :loading, false
  end
end
