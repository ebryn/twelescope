class FixDomainsLinkagesCount < ActiveRecord::Migration
  def self.up
    change_column :links, :linkages_count, :integer
  end

  def self.down
    change_column :links, :linkages_count, :string
  end
end
