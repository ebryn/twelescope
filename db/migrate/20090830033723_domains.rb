class Domains < ActiveRecord::Migration
  def self.up
    rename_column :links, :domain, :domain_name
    create_table :domains do |t|
      t.string :name
      t.string :linkages_count
      t.timestamps
    end
    add_column :links, :domain_id, :integer
    Link.all do |link|
      link.set_domain
    end
  end

  def self.down
    remove_column :links, :domain_id
    drop_table :domains
    rename_column :links, :domain_name, :domain
  end
end
