class AddPageTitlesAndExcerptsToLinks < ActiveRecord::Migration
  def self.up
    add_column :links, :page_title, :text
    add_column :links, :page_excerpt, :text
  end

  def self.down
    remove_column :links, :page_title
    remove_column :links, :page_excerpt
  end
end
