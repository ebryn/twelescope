class UsersController < ApplicationController

  def index
    @users = User.find(:all, :select => "users.*, (SELECT COUNT(*) FROM linkages WHERE users.id = linkages.user_id) AS n", :order => 'twitter_name')
  end
  
  def show
    @user = User.find_by_twitter_name(params[:id])
    unless @user
      flash[:notice] = "We don't know about you yet. Join us!"
      redirect_to( :action => :new, :twitter_name => params[:id] ) and return
    end
    @user_links = @user.links.find(:all, :limit => 25, :select => "links.*, (SELECT COUNT(*) FROM linkages WHERE links.id = linkages.link_id) AS n").sort_by { |l| l.n.to_i }.reverse
    @links = Link.find_by_sql( ["SELECT links.id, url, domain, page_title, COUNT(*) AS n FROM links JOIN linkages ON links.id = link_id JOIN friendships f ON f.friend_id = linkages.user_id WHERE f.user_id = ? GROUP BY links.id, url, domain, page_title ORDER BY COUNT(*) DESC LIMIT 30", @user.id ] )
    @friends = @user.friends.all(:order => "twitter_followers_count DESC")
    @popular_domains = Link.find_by_sql( [ "SELECT domain, COUNT(*) AS n FROM links JOIN linkages ON links.id = link_id JOIN friendships f ON f.friend_id = linkages.user_id WHERE linkages.user_id = ? OR f.user_id = ? GROUP BY domain ORDER BY COUNT(*) DESC LIMIT 25", @user.id, @user.id ] )
  end
  
  def create 
    @user = User.find_or_create_by_twitter_name(params[:id])
    @user.start_loading
    redirect_to user_path @user
  end
end
