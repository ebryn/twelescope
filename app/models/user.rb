require 'grackle'

class User < ActiveRecord::Base
  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :linkages
  
  def fetch_twitter_friends
    @@client ||= Grackle::Client.new
    @@client.statuses.friends.send("#{twitter_id}?")
  end
  
  def create_users_from_twitter_friends
    fetch_twitter_friends.map do |friend|
      friend_record = User.find_or_create_by_twitter_id(friend.screen_name)
      unless self.friends.include?(friend_record)
        self.friendships.create :friend => friend_record
      end
      friend_record.update_attributes(:twitter_friends_count => friend.friends_count, :twitter_followers_count => friend.followers_count)
    end
  end
  
  def find_urls_in_tweets
    @@client ||= Grackle::Client.new
    results = @@client[:search].search.json?(:rpp => 100, :from => self.twitter_id).results
    results.select { |r| r.text.include?('http://') }.
      map { |r| URI.extract(r.text, 'http') }.flatten
  end
  
  def read_friends_twitter_feeds
    self.friends.map do |friend|
      yield [friend, friend.fetch_linkages]
    end
  end
  
  def fetch_linkages
    find_urls_in_tweets.each do |url|
      link = Link.find_or_create_by_url(url)
      self.linkages.create :link => link
    end
  end
end
