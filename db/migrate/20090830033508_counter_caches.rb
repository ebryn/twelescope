class CounterCaches < ActiveRecord::Migration
  def self.up
    add_column :linkages, :domain_id, :integer
    rename_column :links, :global_count, :linkages_count
    #Domain.connection.execute "update links set linkages_count = ( select count(linkages.id) from linkages where linkages.link_id = links.id group_by linkages.link_id )"
  end

  def self.down
    rename_column :links, :linkages_count, :global_count
    remove_column :linkages, :domain_id
  end
end
