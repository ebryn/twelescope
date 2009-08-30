class LinkImages < ActiveRecord::Migration
  def self.up
    add_column :links, :page_type, :string
    add_column :links, :image_url, :string
  end

  def self.down
    remove_column :links, :image_url
    remove_column :links, :page_type
  end
end
