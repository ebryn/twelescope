class AddDomainColumn < ActiveRecord::Migration
  def self.up
    add_column :links, :domain, :string
  end

  def self.down
    remove_column :links, :domain
  end
end
