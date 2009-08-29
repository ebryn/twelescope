class CreateLinkages < ActiveRecord::Migration
  def self.up
    create_table :linkages do |t|
      t.references :link_id
      t.references :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :linkages
  end
end
