class CreateShortLinks < ActiveRecord::Migration
  def self.up
    create_table :short_links do |t|
      t.integer :link_id
      t.string :url
      t.boolean :inactive, :default => false, :nil => false

      t.timestamps
    end
  end

  def self.down
    drop_table :short_links
  end
end
