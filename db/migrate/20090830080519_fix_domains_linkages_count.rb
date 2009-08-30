class FixDomainsLinkagesCount < ActiveRecord::Migration
  def self.up
    change_column :domains, :linkages_count, :integer
  end

  def self.down
    change_column :domains, :linkages_count, :string
  end
end
