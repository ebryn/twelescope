class RedoDomains < ActiveRecord::Migration
  def self.up
    Link.find_in_batches( :conditions => [ "original_url IS NULL and followed = ?", false] ) do |links|
      links.each do |link|
        begin
          next if link.followed? or link.original_url
          link.expand_url
          link.save!
        rescue => e
          nil
        end
      end
    end
  end

  def self.down
  end
end
