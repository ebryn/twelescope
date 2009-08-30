class RemoveShortLinksFromLinks < ActiveRecord::Migration
  def self.up
    Link.all(:conditions => "url != expanded_url AND expanded_url IS NOT NULL").each do |link|
      Link.transaction do
        link.short_links.create! :url => link.url
        link.url = link.expanded_url
        link.save!
      end
    end
    
    remove_column :links, :expanded_url
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
