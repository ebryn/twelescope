class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.string :url
      t.string :expanded_url
      t.integer :global_count

      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
