class ShortLinkages < ActiveRecord::Migration
  def self.up
    add_column :linkages, :shared_url, :string
    add_column :links,    :original_url, :string

    ShortLink.find_in_batches do |shortlinks|
      shortlinks.each do |sl|
        Linkage.update_all [ "shared_link= ?", sl.url ], [ "shared_link is NULL and link_id = ?", sl.link_id ]
      end
    end

  end

  def self.down
    remove_column :links,    :original_url
    remove_column :linkages, :shared_url
  end
end
