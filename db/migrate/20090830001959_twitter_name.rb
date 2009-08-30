class TwitterName < ActiveRecord::Migration
  def self.up
    rename_column :users, :twitter_id, :twitter_name
  end

  def self.down
    rename_column :users, :twitter_name, :twitter_id
  end
end
