class UsersController < ApplicationController
  def index
    
  end
  
  def show
    @user = User.find_or_create_by_twitter_id(params[:id])
    @user_links = @user.links.find(:all, :limit => 25, :select => "links.*, (SELECT COUNT(*) FROM linkages WHERE links.id = linkages.link_id) AS n").sort_by { |l| l.n.to_i }.reverse
    @links = Link.find_by_sql( ["SELECT COALESCE(expanded_url, url) AS url, page_title, COUNT(*) AS n FROM links JOIN linkages ON links.id = link_id JOIN friendships f ON f.friend_id = linkages.user_id WHERE f.user_id = ? GROUP BY COALESCE(expanded_url, url), page_title ORDER BY COUNT(*) DESC LIMIT 30", @user.id ] )
    @friends = @user.friends.all(:order => "twitter_followers_count DESC")
    @popular_domains = Link.find_by_sql( [ "SELECT domain, COUNT(*) AS n FROM links JOIN linkages ON links.id = link_id JOIN friendships f ON f.friend_id = linkages.user_id WHERE f.user_id = ? GROUP BY domain ORDER BY COUNT(*) DESC LIMIT 25", @user.id ] )
  end
  
  def new
    @user = User.find_or_create_by_twitter_id(params[:id])
    Delayed::Job.enqueue @user
    redirect_to user_path(@user.twitter_id)
  end
end
