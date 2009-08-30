class InvalidUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :no_twitter_account, :boolean, :default => false
  end

  def self.down
    remove_column :users, :no_twitter_account
  end
end
