class UsersController < ApplicationController
  def index
    
  end
  
  def show
    @user = User.find_or_create_by_twitter_id(params[:id])
    @user_links = @user.links.find(:all, :limit => 25, :select => "links.*, (SELECT COUNT(*) FROM linkages WHERE links.id = linkages.link_id) AS n").sort_by { |l| l.n.to_i }.reverse
    @links = Link.find_by_sql( ["SELECT IFNULL(expanded_url, url) AS url, page_title, COUNT(*) AS n FROM links JOIN linkages ON links.id = link_id JOIN friendships f ON f.friend_id = linkages.user_id WHERE f.user_id = ? GROUP BY IFNULL(expanded_url, url) HAVING COUNT(*) > 1 ORDER BY COUNT(*) DESC LIMIT 30", @user.id ] )
    @friends = @user.friends.all(:order => "twitter_followers_count DESC")
    @popular_domains = Link.find_by_sql( [ "SELECT domain, COUNT(*) AS n FROM links JOIN linkages ON links.id = link_id JOIN friendships f ON f.friend_id = linkages.user_id WHERE f.user_id = ? GROUP BY domain HAVING COUNT(*) > 1 ORDER BY COUNT(*) DESC LIMIT 25", @user.id ] )
  end
  
  def new
    @user = User.find_or_create_by_twitter_id(params[:id])
    @user.create_users_from_twitter_friends
    render :text => proc { |response, output|
      @user.read_friends_twitter_feeds do |f, links| 
        links.each { |l| output.write(l+"\n") } 
        # output.flush
      end
    }
  end
end
