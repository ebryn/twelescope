class SiteVisitors < ActiveRecord::Migration
  def self.up
    add_column :users, :site_visitor, :boolean
  end

  def self.down
    remove_column :users, :site_visitor
  end
end
