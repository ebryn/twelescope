class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.references :user
      t.string :tag
      t.integer :qty

      t.timestamps
    end
  end

  def self.down
    drop_table :taggings
  end
end
