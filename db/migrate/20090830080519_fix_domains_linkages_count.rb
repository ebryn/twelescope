class FixDomainsLinkagesCount < ActiveRecord::Migration
  def self.up
    remove_column :domains, :linkages_count
    add_column :domains, :linkages_count, :integer
  end

  def self.down
    change_column :domains, :linkages_count, :string
  end
end
