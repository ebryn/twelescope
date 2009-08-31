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

    @user_links = @user.links.paginate(:page => params[:page]) #, :include => {:linkages => :user})
    @friend_links =  Link.find_by_sql( ["SELECT links.id, url, domain_name, page_title, COUNT(*) AS qty FROM links JOIN linkages ON links.id = link_id JOIN friendships f ON f.friend_id = linkages.user_id WHERE f.user_id = ? GROUP BY links.id, url, domain_name, page_title ORDER BY COUNT(*) DESC LIMIT 10", @user.id ] )
      #@user.friend_linkages.popular.map(&:link)
    @friends = @user.friends.popular.all(:limit => 10) #all(:order => "twitter_followers_count DESC")
    @popular_domains = @user.domains.find(:all, :select => "name, COUNT(*) AS qty", :group => "name", :order => "qty DESC", :limit => 10, :conditions => "name is not null")
    #Link.find_by_sql( [ "SELECT domain, COUNT(*) AS n FROM links JOIN linkages ON links.id = link_id JOIN friendships f ON f.friend_id = linkages.user_id WHERE linkages.user_id = ? OR f.user_id = ? GROUP BY domain ORDER BY COUNT(*) DESC LIMIT 25", @user.id, @user.id ] )
    @tags = Tagging.find_by_sql( ["SELECT tag, SUM(qty) AS total_qty FROM taggings t JOIN friendships f ON f.friend_id = t.user_id WHERE f.user_id = ? GROUP BY tag ORDER BY SUM(qty) DESC LIMIT 10", @user.id ] )
  end

  def update
    flash[:notice] = "Reviewing your stream"
    @user = User.find params[:id]
    @user.start_loading
    redirect_to user_path @user
  end
  
  def create 
    @user = User.find_or_create_by_twitter_name(params[:id])
    @user.start_loading
    redirect_to user_path @user
  end
end
