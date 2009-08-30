class User < ActiveRecord::Base
  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :linkages
  has_many :links, :through => :linkages
  has_friendly_id :twitter_name
  has_many :domains, :through => :linkages, :uniq => true
  #has_many :friend_linkages, :through => :friends, :class_name => 'Linkage', :source => :linkages, :uniq => true 

  named_scope :popular, :order => "twitter_followers_count DESC", :limit => 25

  QUEUE_PRIORITY = 5
  include Rehab::Enqueueable
  include Rehab::Tweetable

  def update_from_twitter
    return if no_twitter_account?
    fetch_linkages
    if site_visitor?
      create_users_from_twitter_friends
      read_friends_twitter_feeds
    end
  rescue Rehab::TwitterClient::NoSuchUser
    update_attribute :no_twitter_account, true
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

  def find_urls_in_tweets
    return [] unless eligible_for_tweet_searching?
    results = search_twitter.query( :params => { :rpp => 100, :from => twitter_name } )[:results]
    self.update_attribute :last_searched, Time.now
    results.inject([]) { |urls, tweet| urls << Link.extract_urls(tweet['text']) }.flatten.compact
  end
  
  def read_friends_twitter_feeds
    return unless self.site_visitor?
    self.friends.each { |f| f.enqueue }
  end
  
  def fetch_linkages
    find_urls_in_tweets.each do |url|
      link = ShortLink.find_by_url(url, :include => :link).try(:link) || Link.find_or_create_by_url(url)
      unless self.links.include?(link)
        self.linkages.create :link => link
      end
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
