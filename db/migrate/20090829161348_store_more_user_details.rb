class StoreMoreUserDetails < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_followers_count, :integer
    add_column :users, :twitter_friends_count, :integer
  end

  def self.down
    remove_column :users, :twitter_followers_count
    remove_column :users, :twitter_friends_count
  end
end
