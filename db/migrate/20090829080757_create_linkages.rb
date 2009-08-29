class CreateLinkages < ActiveRecord::Migration
  def self.up
    create_table :linkages do |t|
      t.references :link
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :linkages
  end
end
