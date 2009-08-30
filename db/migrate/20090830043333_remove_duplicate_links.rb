class RemoveDuplicateLinks < ActiveRecord::Migration
  def self.up
    Link.all(:select => "url, COUNT(*) AS dupes", :group => "url HAVING COUNT(*) > 1").map do |dupe_link|
      duplicate_links = Link.find_all_by_url(dupe_link.url, :order => "id")
      master_link = duplicate_links.first
      duplicate_links[1..-1].each do |duplicate_link|
        duplicate_link.linkages.each do |linkage|
          linkage.update_attribute :link_id, master_link.id
        end
        duplicate_link.destroy
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
